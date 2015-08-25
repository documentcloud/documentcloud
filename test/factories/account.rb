FactoryGirl.define do
  factory :account do
    email "bruce@hotmail.com"
    first_name 'Bruce'
    last_name 'Wayne'
    password 'password'
    document_language 'eng'
    language 'eng'

    trait :random do
      email {"bruce_#{SecureRandom.hex(3)}@hotmail.com"}
    end
  end
end
  