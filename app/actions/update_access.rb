require File.dirname(__FILE__) + '/support/setup'

# A background job to update all child models with the correct access level
# of the parent document, and update all assets on S3.
class UpdateAccess < CloudCrowd::Action

  def process
    begin
      ActiveRecord::Base.establish_connection
      access   = options['access']
      document = Document.find(input)
      [Page, Entity, EntityDate].each do |model_klass| 
        model_klass.where(:document_id => document.id).update_all(:access=>access, :status => DC::Status::FROM_ACCESS[access])
      end
      begin
        DC::Store::AssetStore.new.set_access(document, access)
      rescue AWS::S3::Errors::NoSuchKey
        # Quite a few docs are missing text assets
        # Even though they are incomplete, They should still
        # be able to have their access manipulated
      end
      changes = {:access => access}
      changes[:status] = DC::Status::FROM_ACCESS[access]
      document.update_attributes(changes)
    rescue Exception => e
      LifecycleMailer.exception_notification(e,options).deliver
      document.update_attributes(:access => DC::Access::ERROR, :status => DC::Status::ERROR) if document
      raise e
    end
    true
  end

end
