# This file, which is the canonical mapping between Calais and DocumentCloud
# Entity kinds, is used by both the Rails and Javascript Entity models.

module DC

  # The normalized list of entity types that DocumentCloud supports.
  ENTITY_KINDS = [
    :organization, :place, :city, :country, :term, :person, :state,
    :phone, :email
  ]

  # Supported entity kinds as strings for Rails validation.
  VALID_KINDS = ENTITY_KINDS.map(&:to_s)

  # Mapping from OpenCalais entity kinds into DocumentCloud entity kinds.
  # OpenCalais types not on this list don't make the cut.
  CALAIS_MAP = {
    :company            => :organization,
    :organization       => :organization,
    :facility           => :place,
    :natural_feature    => :place,
    :city               => :city,
    :country            => :country,
    :industry_term      => :term,
    :person             => :person,
    :province_or_state  => :state,
    :email_address      => :email,
    :fax_number         => :phone,
    :phone_number       => :phone
  }

end