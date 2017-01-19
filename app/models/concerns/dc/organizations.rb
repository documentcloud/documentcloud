require 'active_support/concern'

module DC::Organizations
  extend ActiveSupport::Concern

  included do
    def create
      # overrides to this method go here
    end

    def update
      # overrides to this method go here
    end

    def role_of(account)
      memberships.where(account_id: account.id).first
    end

    def add_member(account, role, concealed = false)
      options = { account_id: account.id, role: role, concealed: concealed }
      # TODO: transition account#real? for this verification
      options[:default] = true unless account.memberships.exists?(default: true)
      memberships.create(options)
    end

    def remove_member(account)
      memberships.where(account_id: account.id).destroy_all
    end
  end
end
