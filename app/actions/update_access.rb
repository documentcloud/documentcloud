require File.dirname(__FILE__) + '/support/setup'

# A background job to update all child models with the correct access level
# of the parent document, and update all assets on S3.
class UpdateAccess < CloudCrowd::Action

  def process
    begin
      ActiveRecord::Base.establish_connection
      access   = options['access']
      document = Document.find(input)
      [Page, Entity, EntityDate].each{ |model_klass| model_klass.where(:document_id => document.id).update_all(:access=>access) }
      begin
        DC::Store::AssetStore.new.set_access(document, access)
      rescue AWS::S3::Errors::NoSuchKey
        # Quite a few docs are missing text assets
        # Even though they are incomplete, They should still
        # be able to have their access manipulated
      end
      document.update_attributes(:access => access)
    rescue Exception => e
      LifecycleMailer.exception_notification(e,options).deliver_now
      document.update_attributes(:access => DC::Access::ERROR) if document
      raise e
    end
    true
  end

end
