class ReviewersController < ApplicationController

  before_filter :login_required, :load_documents

  def index
    reviewers = {}
    @documents.each do |doc|
      reviewers[doc.id] = doc.reviewers
    end
    email_body = LifecycleMailer.create_reviewer_instructions(@documents, current_account, nil, "<span />").body
    json :reviewers => reviewers, :email_body => email_body
  end

  def create
    account = Account.lookup(params[:email])
    return json(nil, 409) if account && account.id == current_account.id

    account ||= current_organization.accounts.create(
      pick(params, :first_name, :last_name, :email).merge({:role => Account::REVIEWER})
    )

    return json account if account.errors.any?

    @documents.each do |doc|
      doc.add_reviewer(account, current_account)
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

  def send_email
    Accounts.find(params[:account_ids]).each do |account|
      account.send_reviewer_instructions @documents, current_account, params[:message]
    end
    json nil
  end


  private

  def load_documents
    @documents = Document.accessible(current_account, current_organization).find(params[:document_ids])
    if @documents.any? {|d| !current_account.allowed_to_edit?(d) }
      json nil, 403
      false
    end
  end

end