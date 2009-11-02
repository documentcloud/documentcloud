require 'test_helper'

class ValidatorsTest < ActiveSupport::TestCase
    
  context "The library of validation Regexes" do
            
    should "be able to validate domain names" do
      %w(google.com www.documentcloud.org internal.web1.est.example.com).each do |domain|
        assert DC::Validators::DOMAIN.match(domain)
      end
      %w(biz$ness.com google.com;drop google.c login www.microsoft).each do |domain|
        assert !DC::Validators::DOMAIN.match(domain)
      end
    end
    
    should "be able to validate subdomains" do
      %w(web09 internal staging us-eastern CAPHAPPY).each do |subdomain|
        assert DC::Validators::SUBDOMAIN.match(subdomain)
      end
      %w(dollar$ internal.web bim—bop grünter).each do |subdomain|
        assert !DC::Validators::SUBDOMAIN.match(subdomain)
      end
    end
    
    should "be able to validate email addresses" do
      %w(jsmith@example.com jeremy@documentcloud.org bill+peters@gmail.com).each do |email|
        assert DC::Validators::EMAIL.match(email)
      end
      %w(biz[at]docs.com 20#10@gmail.com example@something.somewhere).each do |email|
        assert !DC::Validators::EMAIL.match(email)
      end
    end
    
    # Validation tests to be continued...
    
  end
  
end