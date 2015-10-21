FactoryGirl.define do
  factory :document do
    publication_date Time.now
    text_changed 'f'
    title 'TV Manual'
    original_extension 'pdf'
    description "I forgot to add a description"
    hit_count 1001
    slug 'tv'
    reviewer_count  0 
    #source   
    page_count 68
    #organization 'dallas'
    #calais_id
    public_note_count  102 
    #publish_at
    access DC::Access::PUBLIC
    char_count 146055 
    #related_article
    language 'en'
    file_hash 'a483ba7b72e0571f23d61f5233228c9540ce325b'
    file_size 2662279 
    remote_url 'http://example.com/my_precious'
    #detected_remote_url
    created_at {Time.now - 1.month - 2.days}
    updated_at {Time.now - 1.month - 1.days}
    account
    organization
    # Use random when you want to create a random document/account/organization
    trait :random do
      association :account, :factory => [:account, :random]
      association :organization, :factory => [:organization, :random]
      # account {FactoryGirl.build(:account, :random)}
      # organization {FactoryGirl.build(:organization, :random)}
    end
  end
end