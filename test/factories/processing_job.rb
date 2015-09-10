FactoryGirl.define do
  factory :processing_job do
    title "Entity extractor job"
    action "process_entities"
    cloud_crowd_id "1234"
    account {Account.first || create(:account)}
    document
  end
end