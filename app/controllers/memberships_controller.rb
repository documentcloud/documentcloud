class MembershipsController < ApplicationController
  layout nil

  before_action :login_required
  before_action :read_only_error if read_only?

  def active
    Membership.member?(membership_params)
  end

  def membership_params
    params.permit(:organization_id, :account_id)
  end
end
