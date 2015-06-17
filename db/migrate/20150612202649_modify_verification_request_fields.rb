class ModifyVerificationRequestFields < ActiveRecord::Migration
  def change
    change_table :verification_requests do |t|
      t.remove  :organization_slug,
                :display_language,
                :document_language
      t.string  :industry,         :length => 255
      t.string  :use_case,         :null => true
      t.string  :reference_links,  :null => true
      t.boolean :marketing_optin,  :default => false
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Can't recover Organization Slug, Display Language, or Document Language"
  end
end
