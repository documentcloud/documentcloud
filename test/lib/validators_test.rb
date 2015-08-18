require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
  it "is able to validate domain names" do
    %w(google.com www.documentcloud.org internal.web1.est.example.com).each do |domain|
      assert DC::Validators::DOMAIN.match(domain), "#{domain} should be valid"
    end
    %w(biz$ness.com google.com;drop google.c login).each do |domain|
      refute DC::Validators::DOMAIN.match(domain), "#{domain} should NOT be valid"
    end
  end

  it "validates subdomains" do
    %w(web09 internal staging us-eastern CAPHAPPY).each do |subdomain|
      assert DC::Validators::SUBDOMAIN.match(subdomain), "#{subdomain} should be valid"
    end
    %w(dollar$ internal.web bim—bop grünter).each do |subdomain|
      refute DC::Validators::SUBDOMAIN.match(subdomain), "#{subdomain} should NOT be valid"
    end
  end


  it "can validate email addresses" do
    %w(jsmith@example.com jeremy@documentcloud.org bill+peters@gmail.com).each do |email|
      assert DC::Validators::EMAIL.match(email), "#{email} should be valid"
    end
    %w(biz[at]docs.com 20#10@gmail.com).each do |email|
      refute DC::Validators::EMAIL.match(email), "#{email} should NOT be valid"
    end
  end
  
  def test_validator_for_external_url_requests
    good_urls = %w[
      http://www.documentcloud.org/home
      
    ]
    bad_urls = %w[
      http://127.0.0.1/~ubuntu/.ssh/id_dsa
    ]
    
    good_urls.each{ |url| assert DC::Validators.validate_url(url), "#{url} should be marked as valid." }
    bad_urls.each{ |url|  refute DC::Validators.validate_url(url), "#{url} shouldn't be marked as valid." }
    
  end
end
