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
      def pages( occurs=split_occurrences )
        conds = occurs.map do |occur|
          "(start_offset <= #{occur.offset} and end_offset > #{occur.offset})"
        end
        document.pages.where( conds.join(' or ') )
      end

      def excerpts( context=50, pages=[], occurrences=split_occurrences)
        pgs = self.pages( occurrences ) if pgs.blank?
        page_map = occurrences.inject({}) do |memo, occur|
          page = pgs.detect{|pg| pg.contains?(occur) }
          memo[occur] = page if page
          memo
        end

        page_map.map do |occur, page|
          txt     =  page.text
          open    =  occur.offset - page.start_offset
          close   =  open + occur.length
          first   =  open - context
          last    =  close + context
          last    =  last < txt.length ? context : txt.length - close
          excerpt =  first < 0 ? txt[0, open].to_s : txt[first, context].to_s
          excerpt += "<span class=\"occurrence\">#{ txt[open, occur.length].to_s }</span>"
          excerpt += txt[close, last].to_s if close < txt.length
          {:page_number => page.page_number, :excerpt => excerpt, :offset => occur.offset}
        end
      end

    end

  end
end
