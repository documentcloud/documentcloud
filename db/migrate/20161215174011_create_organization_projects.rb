class CreateOrganizationProjects < ActiveRecord::Migration
  def change
    create_table :organization_projects do |t|
      t.references :organization, index: true, foreign_key: true
      t.references :project, index: true, foreign_key: true

      t.timestamps # null: false
    end
  end
end
