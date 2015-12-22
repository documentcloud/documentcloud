module DC

  module Validators
    
    DOMAIN_BODY = '((?:[a-z0-9\-_]+\.)+[a-z]{2,63})'

    # Forgiving Domain Name validator
    DOMAIN = /\A#{DOMAIN_BODY}\Z/i

    # We're not talking full domains, just (prefix).documentcloud.org
    SUBDOMAIN = /\A[0-9a-z\-_]+\Z/i

    # Proper slugs are alphanumeric, lowercased, with dashes.
    SLUG_TEXT = /\A[\p{Letter}\p{Number}\-]+\Z/

    # Full document ID slugs must start with the numeric ID and contain
    # the alphanumeric slug
    SLUG = /\A[0-9]+-[\p{Letter}\p{Number}\-]+\Z/

    # IP Validation Regex.
    IP = /\A(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\Z/

    # Email validator.
    EMAIL = /\A([\w\.\-\+\=]+)@#{DOMAIN_BODY}\Z/i

    # Login must start with a letter, and only contain lowercase alphanumerics, '.' or '_' thereafter
    LOGIN = /\A[a-z][a-z0-9\._]*\Z/

    # Validate telephone number.
    PHONE = /\A[\s\d\-+x().]{10,25}\Z/

    # Validate ZIP code.
    ZIP_CODE = /\A\d{5}(([+\-\s])?\d{4})?\Z/

    # State Abbreviation list.
    STATES = %w(AL AK AS AZ AR CA CO CT DE DC FL GA GU HI ID IL IN IA KS KY LA ME MD MA MI MN MS MO MT NE NV NH NJ NM NY NC ND OH OK OR PA PR RI SC SD TN TX UT VT VI VA WA WV WI WY)

    # list cribbed from https://en.wikipedia.org/wiki/Reserved_IP_addresses
    # excluding ::ffff:0:0/96 which maps to ipv4 addresses
    RESERVED_IP = %w[
      0.0.0.0/8
      10.0.0.0/8
      100.64.0.0/10
      127.0.0.0/8
      169.254.0.0/16
      172.16.0.0/12
      192.0.0.0/24
      192.0.2.0/24
      192.88.99.0/24
      192.168.0.0/16
      198.18.0.0/15
      198.51.100.0/24
      203.0.113.0/24
      224.0.0.0/4
      240.0.0.0/4
      255.255.255.255/32
      ::/128
      ::1/128
      100::/64
      64:ff9b::/96
      2001::/32
      2001:10::/28
      2001:20::/28
      2001:db8::/32
      2002::/16
      fc00::/7
      fe80::/10
      ff00::/8
    ].map{ |ip_spec| IPAddr.new ip_spec }
    
    # Ensure that a URL does not request a resource
    # from our internal network or any other invalid location
    def self.validate_external_url(url_string)
      # always default to false.
      is_valid = false
      begin
        url = URI.parse(url_string)

        # accept http or https connections
        valid_scheme = ( url.scheme =~ /\Ahttps?\z/i ? true : false )

        # evaluate IP addresses and domain names against blacklist.
        valid_host = case url.host
          when IP
            RESERVED_IP.none?{ |range| range.include? url.host }
          when DOMAIN
            # lookup addresses for domain
            resolved_addresses = Resolv.getaddresses url.host
            # make sure none of the addresses
            resolved_addresses.none? do |address|
              # match any of the reserved IP blocks.
              (RESERVED_IP+restricted_ips).compact.any?{ |range| range.include? address }
            end
          else
            false # if we don't match a valid domain pattern or IP.
        end
        
        is_valid = (valid_scheme and valid_host)
      rescue URI::Error => e
        # don't bother raising an error if the URL is invalid/unparseable
      rescue Resolv::ResolvError, Resolv::ResolvTimeout => e
        # noting DNS resolution errors explicitly here.
        # if resolution fails, definitely throw an error.
        raise e
      end
      is_valid
    end
    
    def self.restricted_ips
      @@restricted_ips ||= nil
      @@last_fetched   ||= nil

      if @@restricted_ips and @@last_fetched and @@last_fetched < 1.hour.ago
        @@restricted_ips 
      else
        Rails.logger.info "fetching ip addresses"
        @@restricted_ips = if Rails.env.test?
          []
        else
          ::AWS::EC2.new.instances.map{ |i| [i.private_ip_address, i.public_ip_address] }.flatten.uniq
        end
        @@last_fetched = Time.now
        @@restricted_ips
      end
    end

  end
end