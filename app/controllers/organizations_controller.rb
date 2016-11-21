# The OrganizationsController is responsible for organization management
class OrganizationsController < ApplicationController
  layout nil

  before_action :login_required
  before_action :read_only_error if read_only?

  # Administrators of an organization can set
  #   the default language for members
  def update
    membership = current_account.memberships.where({
        :role => DC::Roles::ADMINISTRATOR,
        :organization_id => params[:id] }).first
    return forbidden unless membership

    membership.organization.update_attributes pick(params, :language, :document_language)

    json membership.organization.canonical
  end


end
