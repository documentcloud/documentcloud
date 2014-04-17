module DC
  module Store

    # Contains common functionality of sub-document models.
    module DocumentResource

      def self.included(klass)
        klass.class_eval do
          validates :organization_id, :account_id, :document_id, :access, :presence=>true

          before_validation :on=>:create do
            self.document_id      = document.id
            self.organization_id  = organization_id || document.organization_id
            self.account_id       = account_id || document.account_id
            self.access           = access || document.access
          end

        end
      end

    end

  end
end
