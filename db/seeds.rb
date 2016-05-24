# ruby encoding: utf-8
    # DISABLED      = 0
    # ADMINISTRATOR = 1
    # CONTRIBUTOR   = 2
    # REVIEWER      = 3
    # FREELANCER    = 4
# Organizations
Organization.create( name: 'DocumentCloud',
                     slug: 'documentcloud',
                     demo: false, language: 'eng',
                     document_language: 'eng')
# Administrator
Account.create(first_name: 'Administrator',
            last_name: 'Vagrant',
            email: 'admin.test@documentcloud.org',
            language: 'eng',
            document_language: 'eng')

Membership.create( organization: Organization.first, account: Account.first,
                   role: 1)

# Contributor
Account.create(first_name: 'Contributor',
            last_name: 'Vagrant',
            email: 'user.test@documentcloud.org',
            language: 'eng',
            document_language: 'eng')

Membership.create( organization: Organization.first, account: Account.second,
                   role: 2)

# Reviewer
Account.create(first_name: 'Reviewer',
            last_name: 'Vagrant',
            email: 'reviewer.test@documentcloud.org',
            language: 'eng',
            document_language: 'eng')
Membership.create( organization: Organization.first, account: Account.third,
                   role: 3)

# Freelancer
Account.create(first_name: 'Freelancer',
            last_name: 'Vagrant',
            email: 'freelancer.test@documentcloud.org',
            language: 'eng',
            document_language: 'eng')

Membership.create( organization: Organization.first, account: Account.fourth,
                   role: 4)

# Disabled
Account.create(first_name: 'Disabled',
            last_name: 'Vagrant',
            email: 'disabled.test@documentcloud.org',
            language: 'eng',
            document_language: 'eng')

Membership.create( organization: Organization.first, account: Account.fifth,
                   role: 0)

# News XYZ
Organization.create( name: 'News XYZ',
                     slug: 'news-xyz',
                     demo: false, language: 'eng',
                     document_language: 'eng')
# Administrator
Account.create(first_name: 'Administrator',
            last_name: 'Vagrant',
            email: 'admin.test@news-xyz.org',
            language: 'eng',
            document_language: 'eng')

Membership.create( organization: Organization.first, account: Account.last,
                   role: 1)

# Contributor
Account.create(first_name: 'Contributor',
            last_name: 'Vagrant',
            email: 'user.test@news-xyz.org',
            language: 'eng',
            document_language: 'eng')
Membership.create( organization: Organization.first, account: Account.last,
                   role: 2)

# Freelancer
Membership.create( organization: Organization.first, account: Account.fourth,
                   role: 4)

