module DC
  
  module Validators
    
    # Forgiving Domain Name validator (the longest TLD is .museum at the moment)
    DOMAIN = /\A((?:[a-z0-9\-_]+\.)+[a-z]{2,6})\Z/i

    # We're not talking full domains, just (prefix).documentcloud.org
    SUBDOMAIN = /\A[0-9a-z\-_]+\Z/
    
    # Proper slugs are alphanumeric, lowercased, with dashes or underscores.
    SLUG = /\A[a-z0-9\-_]+\Z/

    # IP Validation Regex.
    IP = /\A(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/

    # Email validator.
    # The longest TLD is .museum at the moment.
    EMAIL = /\A([\w\.\-\+\=]+)@((?:[a-z0-9\-_]+\.)+[a-z]{2,6})\Z/i

    # Login must start with a letter, and only contain lowercase alphanumerics, '.' or '_' thereafter
    LOGIN = /\A[a-z][a-z0-9\._]*\Z/

    # Validate telephone number.
    TELEPHONE = /\A[\s\d\-x().]{10,25}\Z/

    # Validate ZIP code.
    ZIP_CODE = /\A\d{5}(([+\-\s])?\d{4})?\Z/

    # State Abbreviation list.
    STATES = %w(AL AK AS AZ AR CA CO CT DE DC FL GA GU HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY)
    
  end
end