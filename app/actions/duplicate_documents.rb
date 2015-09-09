require File.dirname(__FILE__) + '/support/setup'

class DuplicateDocuments < CloudCrowd::Action

  def process
    outcomes = {:succeeded=>[], :failed => []}
    Document.where( {:id => input} ).find_each do |doc|
      begin
        doc.duplicate!(account, options)
      rescue => e
        LifecycleMailer.exception_notification(e, options.merge({:document_id=>doc.id}) ).deliver_now
        outcomes[:failed].push(:id=>doc.id, :access=>doc.access, :error=>{:name=>e.class.name, :message=>e.message})
      end
      outcomes[:succeeded].push(doc.id)
    end
    outcomes
  end
  
  def merge
    # Upon completion email us a manifest of success/failure
    successes = []
    failures = []
    input.each do |result| 
      successes += result["succeeded"]
      failures  += result["failed"]
    end
    
    duplicate_projects(successes) if options['projects']
    
    data = {:successes => successes, :failures => failures}
    LifecycleMailer.logging_email("DuplicateDocument batch manifest", data).deliver_now
    true
  end
  
  private

  def account
    @account ||= Account.find(options['account_id']) if options['account_id']
  end
  
  def duplicate_projects(new_doc_ids)
    new_documents = Document.where(:id=>new_doc_ids)
    projects = Project.where(:id => options['projects'])

    project_document_mapping = Hash[projects.map do |project| 
      document_duplicates_for_project = project.documents.map do |project_document|
        new_documents.find do |cloned_document|
          fields = ["file_hash", "title", "page_count"]
          cloned_attributes = cloned_document.attributes.select{ |key| fields.include? key }
          document_attributes = project_document.attributes.select{ |key| fields.include? key }

          cloned_attributes == document_attributes
        end
      end.compact
      [project, document_duplicates_for_project]
    end]
    
    project_document_mapping.map do |project, docs|
      newattrs = project.attributes
      newattrs.delete("id")
      newattrs.merge!( "account_id" => account.id )
      project = Project.create!(newattrs)
      project.documents = docs.uniq
      project.save
    end
  end
end
