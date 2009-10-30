module DC
  module Store
    
    # Contains common functionality of sub-document models.
    module DocumentResource
      
      def before_validation_on_create
        self.organization_id  = document.organization_id
        self.account_id       = document.account_id
        self.access           = document.access
      end
      
    end
    
  end
end