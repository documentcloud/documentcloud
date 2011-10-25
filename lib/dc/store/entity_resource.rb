module DC
  module Store

    # Common functionality shared by our different entity models.
    module EntityResource

      # Instead of having a separate table for occurrences, we serialize them to
      # a CSV format on each Entity. Deserializes.
      def split_occurrences
        @split_occurrences ||= Occurrence.from_csv(self.occurrences, self)
      end

      # The pages on which this entity occurs within the document.
      def pages(occurs=split_occurrences, options={})
        conds = occurs.map do |occur|
          "(start_offset <= #{occur.offset} and end_offset > #{occur.offset})"
        end
        search = options.merge({:conditions => conds.join(' or ')})
        @pages ||= document.pages.all(search)
        @page_map = occurs.inject({}) do |memo, occur|
          page = @pages.detect {|page| page.contains?(occur) }
          memo[occur] = page if page
          memo
        end
        @pages
      end

      def excerpts(context=50, options={}, occurrences=nil)
        pages(occurrences || split_occurrences, options)
        @page_map.map do |occur, page|
          utf     =  page.text.mb_chars
          open    =  occur.offset - page.start_offset
          close   =  open + occur.length
          first   =  open - context
          last    =  close + context
          last    =  last < utf.length ? context : utf.length - close
          excerpt =  first < 0 ? utf[0, open].to_s : utf[first, context].to_s
          excerpt += "<span class=\"occurrence\">#{ utf[open, occur.length].to_s }</span>"
          excerpt += utf[close, last].to_s if close < utf.length
          {:page_number => page.page_number, :excerpt => excerpt, :offset => occur.offset}
        end
      end

    end

  end
end