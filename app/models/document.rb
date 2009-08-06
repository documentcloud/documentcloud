# NB: Doesn't inherit from ActiveRecord::Base ... yet.
class Document
  
  # Reproduce would-be attributes of a made-up document entry.
  # Optionally specify the top N entities to return.
  def self.generate_fake_entry(num_entities=10)
    {
      'title'         => Faker::Lorem.words(rand(10) + 2).join(' '),
      'author'        => Faker::Name.name,
      'organization'  => Faker::Company.name,
      'created_at'    => rand(600).days.from_now,
      'summary'       => Faker::Lorem.paragraph,
      'entities'      => Array.new(num_entities).map { Entity.generate_fake_entity }
    }
  end
  
end