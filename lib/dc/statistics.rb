require 'dc/csv'

module DC

  # A static module for running statistical counts an aggregations for
  # internal purposes.
  module Statistics

    START_DATE = Date.parse 'March 1, 2010'

    # Count the number of uploaded documents for each day in the past week.
    def self.daily_documents(since=nil)
      Document.where( since_clause(since) ).group("date(created_at)").count
    end

    # Count the number of uploaded pages for each day in the past week.
    def self.daily_pages(since=nil)
      Document.where( since_clause(since) ).group("date(created_at)").sum(:page_count)
    end

    # Count the number of uploaded documents for each day in the past week.
    def self.weekly_documents(since=nil)
      Document.where( since_clause(since) ).group("date_trunc('week', created_at)").count
    end

    # Count the number of uploaded pages for each day in the past week.
    def self.weekly_pages(since=nil)
      Document.where( since_clause(since) ).group("date_trunc('week', created_at)").sum(:page_count)
    end

    # Count the number of hits per day for embedded documents.
    def self.daily_hits_on_documents(since=nil)
      RemoteUrl.where( type_and_since_clause('document_id', since) ).group( :date_recorded ).sum(:hits)
    end

    # Count the number of hits per week for embedded documents.
    def self.weekly_hits_on_documents(since=nil)
      RemoteUrl.where( type_and_since_clause('document_id', since) )
        .group( "date_trunc('week', date_recorded)" )
        .sum(:hits)
    end

    # Count the number of hits per day for embedded notes.
    def self.daily_hits_on_notes(since=nil)
      RemoteUrl.where( type_and_since_clause('note_id', since) ).group( :date_recorded ).sum(:hits)
    end

    # Count the number of hits per week for embedded notes.
    def self.weekly_hits_on_notes(since=nil)
      RemoteUrl.where( type_and_since_clause('note_id', since) ).group( "date_trunc('week', date_recorded)" ).sum(:hits)
    end

    # Count the number of hits per day for embedded searches.
    def self.daily_hits_on_searches(since=nil)
      RemoteUrl.where( type_and_since_clause('search_query', since) ).group( :date_recorded ).sum(:hits)
    end

    # Count the number of hits per week for embedded searches.
    def self.weekly_hits_on_searches(since=nil)
      RemoteUrl.where( type_and_since_clause('search_query', since) ).group( "date_trunc('week', date_recorded)" ).sum(:hits)
    end

    # Implementation of default "since" conditions.
    def self.since_clause(since=nil)
      ['created_at > ?', since || START_DATE]
    end

    def self.type_and_since_clause(type, since=nil)
      ["#{type} is not NULL and created_at > ?", since || START_DATE]
    end

    # Count the total number of uploaded pages since a certain date.
    def self.pages_since(date)
      Document.where( 'created_at > ?', date ).sum('page_count')
    end

    # Count the number of uploaded documents by account.
    def self.public_documents_per_account
      Document.unrestricted.group( :account_id ).count
    end

    # Count the number of uploaded documents by account.
    def self.private_documents_per_account
      Document.restricted.group( :account_id ).count
    end

    # Count the number of uploaded pages by account.
    def self.pages_per_account
      Document.group(:account_id).sum(:page_count)
    end

    # The total number of pages, period.
    def self.total_pages
      Document.sum( :page_count )
    end

    # Return `over_time` for Documents, Pages, Accounts, Organizations.
    def self.by_the_numbers
      # google and "explain analyze" says group by is faster than select distinct
      # either is a sequential scan. We should consider indexing on the columns
      active_org_ids = Document.group('organization_id').pluck('organization_id')
      active_acc_ids = Document.group('account_id').pluck('account_id')

      hash = ActiveSupport::OrderedHash.new
      hash["All Organizations"]     = over_time Organization
      hash["Active Organizations"]  = over_time Organization.where( 'id in (?)', active_org_ids )
      hash["All Accounts"]          = over_time Account
      hash["Active Accounts"]       = over_time Account.where( 'id in (?)', active_acc_ids )
      hash["Reviewers"]             = over_time Account.includes('memberships').references('memberships')
                                                 .where( "memberships.role = ?", Account::REVIEWER )
      hash["Documents"]             = over_time Document
      hash["Pages"]                 = pages_over_time
      hash["Notes"]                 = over_time Annotation
      hash
    end

    # Return the number of X created in the past week, past month, past 6 months
    # ... and total.
    def self.over_time(scope, conditions={})
      { :total      => scope.count,
        :day        => scope.where('created_at > ?', 1.day.ago).count,
        :week       => scope.where('created_at > ?', 1.week.ago).count,
        :month      => scope.where('created_at > ?', 1.month.ago).count,
        :half_year  => scope.where('created_at > ?', 6.months.ago).count
      }
    end

    # Special case to calculate the pages over time.
    def self.pages_over_time
      { :total      => total_pages,
        :day        => pages_since(1.day.ago),
        :week       => pages_since(1.week.ago),
        :month      => pages_since(1.month.ago),
        :half_year  => pages_since(6.months.ago)
      }
    end

    # The pages/per/minute we've processed for the last ten documents.
    # Super-approximate.
    def self.pages_per_minute
      docs = Document.finished.chronological.limit(5).pluck('created_at, updated_at, page_count')
      pages_per_minute = docs.map do | created_at, updated_at, page_count |
        page_count / ((updated_at - created_at) / 1.minute)
      end
      (pages_per_minute.inject(0) {|sum, per| sum + per } / 5).round rescue 0
    end

    # Count the total number of documents, grouped by access level.
    def self.documents_by_access
      Document.group(:access).count
    end

    # Get the average number of pages in a document.
    def self.average_page_count
      Document.average('page_count').to_f.round
    end

    # Get the average number of entities in a document.
    def self.average_entity_count
      Entity.from('(select count(*) c from entities group by document_id) counts').pluck('avg(c)').first
    end

    def self.embedded_document_count
      Document.unrestricted.published.count
    end

    def self.remote_url_hits_last_week
      RemoteUrl.where('date_recorded > ?', 7.days.ago).sum(:hits)
    end

    def self.remote_url_hits_all_time
      RemoteUrl.sum(:hits)
    end

    def self.count_organizations_embedding
      Document.published.group('organization_id').count.length
    end

    def self.count_total_collaborators
      Collaboration.count - Project.count
    end

    def self.top_documents_csv
      documents = RemoteUrl.top_documents(365, 1000)
      DC::CSV::generate_csv(documents)
    end

    def self.accounts_csv(csv)
      keys = Account.first.canonical(:include_document_counts => true, :include_organization => true).keys
      csv << keys.map{ |key| key.titleize }
      Account.find_each do | account |
        record = account.canonical(:include_document_counts => true, :include_organization => true)
        csv << keys.map {|key| record[key] }
      end
    end
    
    def self.new_accounts_since(from, to=Time.now)
      Account.joins(:memberships, :organizations).where('accounts.created_at >= ? and accounts.created_at <= ?', from, to)
    end
    
    def self.new_organizations_since(from, to=Time.now)
      Organization.where('created_at >= ? and created_at <= ?', from, to)
    end

    # To Do: set up a general notifier.
    # Should take a webhook url and a json payload to send.
    def self.notify_top_ten
      top_ten_hits = RemoteUrl.where('document_id is not null and date_recorded = ?',Time.now.utc.to_date).group('document_id').order("sum_hits desc").limit(10).sum('hits')
      data = top_ten_hits.map do |id, hits|
        doc = Document.find(id)
        {
          'title' => doc.title,
          'contributor' => doc.account.full_name,
          'organization' => doc.organization.name,
          'embedded_url' => doc.published_url || doc.detected_remote_url,
          'canonical_url' => doc.canonical_url(:html),
          'hits'  => hits
        }
      end

      text = "Top ten most popular documents today\n"
      text += data.map{ |d| "#{d['hits']}: <#{d['embedded_url']}|#{d['title']}> (<#{d['canonical_url']}|DC>) by #{d['contributor']} (#{d['organization']})" }.join("\n")
      hook_url = DC::SECRETS['slack_webhook']
      data = {:payload => {:text => text, :username => "docbot", :icon_emoji => ":doccloud:"}.to_json}
      RestClient.post(hook_url, data)
    end
  end

end
