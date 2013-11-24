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

    if membership.organization.language != params[:language]
      Document.find(:all,:conditions=>{:organization_id=>membership.organization_id}).each do | doc |
        expire_page doc.canonical_cache_path if doc.cacheable?
      end
    end

    membership.organization.update_attributes pick(params, :language, :document_language)

    json membership.organization.canonical
  end


end
