class ReviewersController < ApplicationController

  before_filter :login_required

  def index
    reviewers = {}
    documents = Document.accessible(current_account, current_organization).find(params[:document_ids])
    documents.each do |doc|
      return json(nil, 403) unless current_account.allowed_to_edit?(doc)
      reviewers[document_id] = doc.reviewers
    end
    email_body = LifecycleMailer.create_reviewer_instructions(documents, current_account, nil, "<span />").body
    json :reviewers => reviewers, :email_body => email_body
  end

  def create
    account = Account.lookup(params[:email])
    return json(nil, 409) if account && account.id == current_account.id

    account ||= current_organization.accounts.create(
      pick(params, :first_name, :last_name, :email).merge({:role => Account::REVIEWER})
    )

    return json account if account.errors.any?

    documents = Documents.find(params[:documents])
    documents.each do |doc|
      doc.add_reviewer(account, current_account) if current_account.allowed_to_edit? doc
    end

    json :account => account, :documents => documents
  end

  def destroy
    account = Account.find(params[:account_id])
    documents = params[:documents].map do |document_id|
      document = Document.find(document_id)
      return json(nil, 403) unless current_account.allowed_to_edit?(document)
      document.remove_reviewer(account)
      document.reload
    end
    json documents
  end

  def update
    account   = current_organization.accounts.find(params[:id])
    is_owner  = current_account.id == account.id
    return json(nil, 403) unless account && (current_account.admin? || is_owner)
    account.update_attributes pick(params, :first_name, :last_name, :email) if account.role == Account::REVIEWER
    json account
  end

  def send_email
    return json(nil, 400) unless params[:accounts] && params[:documents]
    documents = []
    params[:documents].each do |document_id|
      document = Document.find(document_id)
      return json(nil, 403) unless current_account.allowed_to_edit?(document)
      documents << document
    end
    params[:accounts].each do |account_id|
      account = Account.find(account_id)
      account.send_reviewer_instructions(documents, current_account, params[:message])
    end
    json nil
  end


  private

  def current_document
    @document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end