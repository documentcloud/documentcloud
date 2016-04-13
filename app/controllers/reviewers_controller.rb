class ReviewersController < ApplicationController
  include DC::Sanitized

  before_action :login_required, :load_documents

  READONLY_ACTIONS = [
    :index, :preview_email, :send_email
  ]
  before_action :read_only_error, :except => READONLY_ACTIONS if read_only?

  def index
    reviewers = {}
    @documents.each {|doc| reviewers[doc.id] = doc.reviewers }
    json :reviewers => reviewers
  end

  def create
    account = Account.lookup(params[:email])
    if account
      return conflict if account.id == current_account.id
      return bad_request(:error => 'The account associated with that email address has been disabled.') if account.disabled?( current_organization )
    else
      account = Account.create( pick(params, :first_name, :last_name, :email) )
      unless account.new_record?
        current_organization.memberships.create({ :role=> Account::REVIEWER, :account=> account, :default=>true })
      end
    end

    return json account if account.errors.any?

    @documents.each do |doc|
      doc.add_reviewer(account, current_account)
      doc.reload
    end

    json :account => account, :documents => @documents
  end

  def destroy
    account = Account.find(params[:account_id])
    @documents.each do |doc|
      doc.remove_reviewer account
      doc.reload
    end
    json @documents
  end

  def preview_email
    @email = sanitize LifecycleMailer.create_reviewer_instructions(@documents, current_account, nil, params[:message]).body
    render :layout => nil
  end

  def send_email
    Account.find(params[:account_ids]).each do |account|
      account.send_reviewer_instructions @documents, current_account, params[:message]
    end
    json nil
  end


  private

  def load_documents
    @documents = Document.accessible(current_account, current_organization).find(params[:document_ids])
    return forbidden if @documents.any? {|d| !current_account.allowed_to_edit?(d) }
  end

end
