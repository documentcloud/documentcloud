tribune = Organization.create!(
  :name => "The Daily Tribune",
  :slug => "daily-tribune"
)

admin = Account.create!(
  :first_name   => "Jeremy",
  :last_name    => "Ashkenas",
  :organization => tribune,
  :email        => 'jashkenas@gmail.com'
)
admin.password = 'REDACTED'
admin.save

['The Manhattan Project', '2052 Berkeley Olympics', 'President Spitzer',
'The Henderson Report', 'NASA / Return to Mercury', 'Goldman Sachs Embargo',
'National Geographic', 'EPA / Flouride Contamination / Indianapolis'].each do |title|
  Label.create!(:account => admin, :title => title)
end

["person:bush position:president", "city:berkeley", "person:rizzo waterboard",
"category:technology semantic"].each do |search|
  SavedSearch.create!(:account => admin, :query => search)
end