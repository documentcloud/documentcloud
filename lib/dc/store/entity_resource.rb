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
      def pages(occurs=split_occurrences)
        conds = occurs.map do |occur|
          "(start_offset <= #{occur.offset} and end_offset > #{occur.offset})"
        end
        document.pages.all(:conditions => conds.join(' or '), :select => 'id, page_number, start_offset, end_offset')
      end

      # This method has to read the entire document contents into memory and
      # convert to UTF8. Only for debugging, please.
      def occurrence_text(context=0)
        utf = document.text.mb_chars
        split_occurrences.map do |occur|
          utf[occur.offset - context, occur.length + (context * 2)].to_s
        end
      end

    end

  end
end