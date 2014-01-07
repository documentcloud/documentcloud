module DocumentConcerns
  module Annotatable
    extend ActiveSupport::Concern


    def annotations_with_authors(account, annotations=nil)
      annotations ||= ordered_annotations(account)
      Annotation.populate_author_info(annotations, account)
      annotations
    end

    def ordered_annotations(account)
      self.annotations.accessible(account).order('page_number asc, location asc nulls first')
    end

    # Determine the number of annotations on each page of this document.
    def per_page_annotation_counts
      self.annotations.group('page_number').count
    end

    # Reset the cached counter of public notes on the document.
    def reset_public_note_count
      count = annotations.unrestricted.count
      if count != self.public_note_count
        update_attributes :public_note_count => count
      end
    end



  end
end