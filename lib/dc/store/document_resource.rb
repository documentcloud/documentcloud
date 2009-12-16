module DC
  module Store

    # Contains common functionality of sub-document models.
    module DocumentResource

      def before_validation_on_create
        self.document_id      = document.id
        self.organization_id  = document.organization_id
        self.account_id       = document.account_id
        # TODO: deal with access more granularly.
        self.access           = document.access
      end

      def self.included(klass)
        klass.class_eval do
          validates_presence_of :organization_id, :account_id, :document_id, :access
        end
      end

    end

  end
end