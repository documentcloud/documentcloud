class OrganizationProject < ActiveRecord::Base

  belongs_to :organization
  belongs_to :project

  validates :project_id, uniqueness: { scope: :organization_id }
end
