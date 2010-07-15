module DC

  # A static module for running statistical counts an aggregations for
  # internal purposes.
  module Statistics

    # Count the number of uploaded documents for each day in the past week.
    def self.daily_documents(since=nil)
      since ||= 1.week.ago
      Document.count(:group => 'date(created_at)', :conditions => ['created_at > ?', since])
    end

    # Count the number of uploaded pages for each day in the past week.
    def self.daily_pages(since=nil)
      since ||= 1.week.ago
      Document.sum('page_count', :group => 'date(created_at)', :conditions => ['created_at > ?', since])
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
      Page.count(:group => 'account_id')
    end

    # The total number of pages, period.
    def self.total_pages
      Page.count
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
    
    def self.remote_url_hits_last_week
      RemoteUrl.sum(:hits, :conditions => ['date_recorded > ?', 7.days.ago])
    end
    
    def self.remote_url_hits_last_year
      RemoteUrl.sum(:hits, :conditions => ['date_recorded > ?', 365.days.ago])
    end
    
    def self.count_organizations_embedding
      document_ids = RemoteUrl.all(:select => 'document_id', :group => 'document_id').map &:document_id
      Document.find(document_ids).map {|d| d.organization.id }.uniq.length
    end
    
    def self.count_total_collaborators
      Collaboration.count - Project.count
    end
    
  end

end