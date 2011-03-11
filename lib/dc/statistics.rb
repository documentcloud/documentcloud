module DC

  # A static module for running statistical counts an aggregations for
  # internal purposes.
  module Statistics

    START_DATE = Date.parse 'March 1, 2010'

    # Count the number of uploaded documents for each day in the past week.
    def self.daily_documents(since=nil)
      Document.count :group => 'date(created_at)', :conditions => since_clause(since)
    end

    # Count the number of uploaded pages for each day in the past week.
    def self.daily_pages(since=nil)
      Document.sum 'page_count', :group => 'date(created_at)', :conditions => since_clause(since)
    end

    # Count the number of uploaded documents for each day in the past week.
    def self.weekly_documents(since=nil)
      Document.count :group => "date_trunc('week', created_at)", :conditions => since_clause(since)
    end

    # Count the number of uploaded pages for each day in the past week.
    def self.weekly_pages(since=nil)
      Document.sum 'page_count', :group => "date_trunc('week', created_at)", :conditions => since_clause(since)
    end

    # Count the number of hits per day for embedded documents.
    def self.daily_hits(since=nil)
      RemoteUrl.sum :hits, :group => 'date_recorded', :conditions => since_clause(since)
    end

    # Count the number of hits per week for embedded documents.
    def self.weekly_hits(since=nil)
      RemoteUrl.sum :hits, :group => "date_trunc('week', date_recorded)", :conditions => since_clause(since)
    end

    # Implementation of default "since" conditions.
    def self.since_clause(since=nil)
      ['created_at > ?', since || START_DATE]
    end

    # Count the total number of uploaded pages since a certain date.
    def self.pages_since(date)
      Document.sum('page_count', :conditions => ['created_at > ?', date])
    end

    # Count the number of uploaded documents by account.
    def self.public_documents_per_account
      Document.unrestricted.count(:group => 'account_id')
    end

    # Count the number of uploaded documents by account.
    def self.private_documents_per_account
      Document.restricted.count(:group => 'account_id')
    end

    # Count the number of uploaded pages by account.
    def self.pages_per_account
      Document.sum('page_count', :group => 'account_id')
    end

    # The total number of pages, period.
    def self.total_pages
      Document.sum('page_count')
    end

    # Return `over_time` for Documents, Pages, Accounts, Organizations.
    def self.by_the_numbers
      active_org_ids = Document.connection.select_values "select distinct organization_id from documents"
      active_acc_ids = Document.connection.select_values "select distinct account_id from documents"

      hash = ActiveSupport::OrderedHash.new
      hash["All Organizations"]     = over_time Organization
      hash["Active Organizations"]  = over_time Organization.scoped(:conditions => {:id => active_org_ids})
      hash["All Accounts"]          = over_time Account
      hash["Active Accounts"]       = over_time Account.scoped(:conditions => {:id => active_acc_ids})
      hash["Reviewers"]             = over_time Account.scoped(:conditions => {:role => Account::REVIEWER})
      hash["Documents"]             = over_time Document
      hash["Pages"]                 = pages_over_time
      hash["Notes"]                 = over_time Annotation
      hash
    end

    # Return the number of X created in the past week, past month, past 6 months
    # ... and total.
    def self.over_time(model, conditions={})
      { :total      => model.count,
        :day        => model.count(:conditions => ['created_at > ?', 1.day.ago]),
        :week       => model.count(:conditions => ['created_at > ?', 1.week.ago]),
        :month      => model.count(:conditions => ['created_at > ?', 1.month.ago]),
        :half_year  => model.count(:conditions => ['created_at > ?', 6.months.ago])
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
      docs = Document.finished.chronological.all(:limit => 5, :select => 'created_at, updated_at, page_count')
      pages_per_minute = docs.map do |doc|
        doc.page_count / ((doc.updated_at - doc.created_at) / 1.minute)
      end
      (pages_per_minute.inject(0) {|sum, per| sum + per } / 5).round rescue 0
    end

    # Count the total number of documents, grouped by access level.
    def self.documents_by_access
      Document.count(:group => 'access')
    end

    # Get the average number of pages in a document.
    def self.average_page_count
      Document.average('page_count').to_f.round
    end

    # Get the average number of entities in a document.
    def self.average_entity_count
      result = Entity.connection.execute('select avg(c) from (select count(*) as c from entities group by document_id) as entity_counts')
      result[0][0].to_f.round
    end

    def self.embedded_document_count
      Document.unrestricted.published.count
    end

    def self.remote_url_hits_last_week
      RemoteUrl.sum(:hits, :conditions => ['date_recorded > ?', 7.days.ago])
    end

    def self.remote_url_hits_last_year
      RemoteUrl.sum(:hits, :conditions => ['date_recorded > ?', 365.days.ago])
    end

    def self.count_organizations_embedding
      Document.published.count(:group => 'organization_id').length
    end

    def self.count_total_collaborators
      Collaboration.count - Project.count
    end
    
    def self.top_documents_csv
      documents = RemoteUrl.top_documents(365, :limit => 1000)
      DC::CSV::generate_csv(documents)
    end
    
    def self.accounts_csv
      accounts = Account.all.map {|a| a.canonical(:include_document_counts => true,
                                                  :include_organization => true) }
      columns  = accounts.first.keys.sort_by {|key| Account.column_names.index(key) || 1000 }
      # columns = Account.column_names | Account.first.canonical(:include_document_counts => true).keys
      DC::CSV::generate_csv(accounts, columns)
    end
  end

end