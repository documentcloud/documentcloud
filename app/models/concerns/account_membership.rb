require 'active_support/concern'

module AccountMembership
  extend ActiveSupport::Concern

  included do
    def member_of?(org)
      self.memberships.exists?(organization_id: org.id)
    end

    def can_switch_to_organization?(organization_id)
      organization = Organization.find_by_id(organization_id)
      return false if !organization # organization does not exists so can't switch to it
      self.member_of?(organization)
    end
  end
end
