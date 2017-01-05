# ruby encoding: utf-8
    # DISABLED      = 0
    # ADMINISTRATOR = 1
    # CONTRIBUTOR   = 2
    # REVIEWER      = 3
    # FREELANCER    = 4
# Organizations

case Rails.env

when 'development' || 'staging'

  def password
    'test1234'
  end

  Organization.delete_all
  Membership.delete_all
  Account.delete_all

  Organization.create(name: 'DocumentCloud',
                      slug: 'documentcloud',
                      demo: false, language: 'eng',
                      document_language: 'eng')

  # SiteAdministrator
  Account.create(first_name: 'SiteAdministrator',
                 last_name: 'Test',
                 email: 'siteadmin.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: 'test1234')

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('siteadmin.test@documentcloud.org'),
                    role: 1,
                    default: true)

  # Administrator
  Account.create(first_name: 'Administrator',
                 last_name: 'Vagrant',
                 email: 'administrator.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('administrator.test@documentcloud.org'),
                    role: 1,
                    default: true)

  # Contributor
  Account.create(first_name: 'Contributor',
                 last_name: 'Vagrant',
                 email: 'contributor.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('contributor.test@documentcloud.org'),
                    role: 2,
                    default: true)

  # Reviewer
  Account.create(first_name: 'Reviewer',
                 last_name: 'Vagrant',
                 email: 'reviewer.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('reviewer.test@documentcloud.org'),
                    role: 3,
                    default: true)

  # Freelancer
  Account.create(first_name: 'Freelancer',
                 last_name: 'Vagrant',
                 email: 'freelancer.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('freelancer.test@documentcloud.org'),
                    role: 4,
                    default: true)

  # Disabled
  Account.create(first_name: 'Disabled',
                 last_name: 'Vagrant',
                 email: 'disabled.test@documentcloud.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('documentcloud'),
                    account: Account.find_by_email('disabled.test@documentcloud.org'),
                    role: 0,
                    default: true)

  # News XYZ
  Organization.create(name: 'News XYZ',
                      slug: 'news-xyz',
                      demo: false, language: 'eng',
                      document_language: 'eng')
<<<<<<< HEAD
=======

  Membership.create(organization: Organization.find_by_slug('news-xyz'),
                    account: Account.find_by_email('siteadmin.test@documentcloud.org'),
                    role: 1,
                    default: false)

>>>>>>> 7a2e074002088b072121d98079230ced2c1c9968
  # Administrator
  Account.create(first_name: 'Administrator',
                 last_name: 'Vagrant',
                 email: 'administrator.test@news-xyz.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

<<<<<<< HEAD
  Membership.create(organization: Organization.find_by_slug('documentcloud'),
=======
  Membership.create(organization: Organization.find_by_slug('news-xyz'),
>>>>>>> 7a2e074002088b072121d98079230ced2c1c9968
                    account: Account.find_by_email('administrator.test@news-xyz.org'),
                    role: 1,
                    default: true)

  # Contributor
  Account.create(first_name: 'Contributor',
                 last_name: 'Vagrant',
                 email: 'contributor.test@news-xyz.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: password)

  Membership.create(organization: Organization.find_by_slug('news-xyz'),
                    account: Account.find_by_email('contributor.test@news-xyz.org'),
                    role: 2,
                    default: true)

  # Freelancer
  Membership.create(organization: Organization.find_by_slug('news-xyz'),
                    account: Account.find_by_email('freelancer.test@documentcloud.org'),
                    role: 4)

  # Legacy Organization - Users not seeded in circlet and with different passwords, Siteadmin is a contributor
  Organization.create(name: 'Legacy Newsroom EFG',
                      slug: 'legacy-newsroom-efg',
                      demo: false,
                      language: 'eng',
                      document_language: 'eng')

  # Administrator
  Account.create(first_name: 'Administrator',
                 last_name: 'Vagrant',
                 email: 'admin.test@legacy-newsroom-efg.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: 'test0000')

  Membership.create(organization: Organization.find_by_slug('legacy-newsroom-efg'),
                    account: Account.find_by_email('admin.test@legacy-newsroom-efg.org'),
                    role: 1,
                    default: true)

  # Contributor
  Account.create(first_name: 'LegacyContributor',
                 last_name: 'Vagrant',
                 email: 'legacycontributor.test@legacy-newsroom-efg.org',
                 language: 'eng',
                 document_language: 'eng',
                 password: 'test1111')

  Membership.create(organization: Organization.find_by_slug('legacy-newsroom-efg'),
                    account: Account.find_by_email('legacycontributor.test@legacy-newsroom-efg.org'),
                    role: 2,
                    default: true)

  Membership.create(organization: Organization.find_by_slug('legacy-newsroom-efg'),
                    account: Account.find_by_email('legacycontributor.test@legacy-newsroom-efg.org'),
                    role: 2,
                    default: true)

  # Freelancer
  Account.create(first_name: 'LegacyFreelancer',
                 last_name: 'Vagrant',
                 email: 'legacyfreelancer.test@johndoe.com',
                 language: 'eng',
                 document_language: 'eng',
                 password: 'test2222')

  Membership.create(organization: Organization.find_by_slug('legacy-newsroom-efg'),
                    account: Account.find_by_email('freelancer.test@documentcloud.org'),
                    role: 4)

  Membership.create(organization: Organization.find_by_slug('legacy-newsroom-efg'),
                    account: Account.find_by_email('administrator.test@news-xyz.org'),
                    role: 4)


end
