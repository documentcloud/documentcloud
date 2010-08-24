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

      def excerpts(context=50, options={})
        pages(split_occurrences, options)
        @page_map.map do |occur, page|
          utf   = page.text.mb_chars
          open  = occur.offset - page.start_offset
          close = open + occur.length
          excerpt =
            utf[open - context, context].to_s + '<span class="occurrence">' +
            utf[open, occur.length].to_s      + '</span>' +
            utf[close, context].to_s
          {:page_number => page.page_number, :excerpt => excerpt}
        end
      end

    end

  end
end