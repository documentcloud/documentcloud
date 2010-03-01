# This file, which is the canonical mapping between Calais and DocumentCloud
# Metadata kinds, is used by both the Rails and Javascript Metadatum models.
# TODO: Turn this into a YAML file. Make Metadata.js rely on it. Until then,
# keep the two in sync.

module DC

  # The normalized list of metadata kinds that DocumentCloud supports.
  METADATA_KINDS = [
    :organization, :place, :city, :country, :term, :person, :state, :date
  ]

  # Supported metadata kinds as strings for Rails validation.
  VALID_KINDS = METADATA_KINDS.map(&:to_s)

  # Mapping from OpenCalais metadata kinds into DocumentCloud metadata kinds.
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
    :province_or_state  => :state
  }

end