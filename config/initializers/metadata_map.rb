# This file, which is the canonical mapping between Calais and DocumentCloud
# Metadata kinds, is used by both the Rails and Javascript Metadatum models.
# TODO: Turn this into a YAML file. Make Metadata.js rely on it. Until then,
# keep the two in sync.

module DC
  
  CALAIS_KINDS = [
    :city, :company, :continent, :country, :email_address, :facility, 
    :holiday, :industry_term, :natural_feature, :organization, :person,
    :position, :product, :province_or_state, :published_medium, :region,
    :technology, :url
  ]
  
end