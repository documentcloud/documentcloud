# The OrganizationsController is responsible for organization management

class OrganizationsController < ApplicationController
  layout 'workspace'

  # Administrators of an organization can set
  #   the default language for members
  def update
    membership = current_account.memberships.find(:first,
                   :conditions=>{ :role            => DC::Roles::ADMINISTRATOR,
                                  :organization_id => params[:id] })
    return forbidden unless membership

    membership.organization.update_attributes pick(params, :language)

    json membership.organization.canonical
  end


end
