FactoryGirl.define do
  factory :organization do
    name "The Daily Beast"
    slug "bst"
    document_language "eng"
    language "eng"

    trait :random do
      name {"The Daily Beast Ed. #{SecureRandom.hex(3)}"}
      slug {SecureRandom.hex(3)}
    end
  end  
end