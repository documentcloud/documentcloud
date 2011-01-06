class ReviewersController < ApplicationController

  def index
    json current_document.reviewers.to_json
  end
  
  def add_reviewer
    documents = []
    account = Account.lookup(params[:email])
    return json(nil, 409) if account and account.id == current_account.id
    
    if account.nil? || !account.id
      attributes = {
        :first_name => params[:first_name],
        :last_name  => params[:last_name],
        :email      => params[:email],
        :role       => Account::REVIEWER
      }
      account = current_organization.accounts.create(attributes)
    end

    if account.id
      documents = params[:documents].map do |document_id|
        document = Document.find(document_id)
        document.document_reviewers.create(:account => account)
        account.send_reviewer_instructions(document, current_account)
        document.reload
      end
    end
    
    if not account.errors.empty?
      json account
    else
      json({:account => account, :documents => documents})
    end
  end
  
  def remove_reviewer
    account = Account.find(params[:account_id])
    documents = params[:documents].map do |document_id|
      document = Document.find(document_id)
      document.document_reviewers.owned_by(account).first.destroy
      document.reload
    end
    json documents
  end
  
  def send_instructions
    params[:accounts].each do |account_id|
      account = Account.find(account_id)
      params[:documents].each do |document_id|
        document = Document.find(document_id)
        account.send_reviewer_instructions(document, current_account)
      end
    end
    json nil
  end

  def update
    account   = current_organization.accounts.find(params[:id])
    is_owner  = current_account.id == account.id
    resend    = account.email != params[:email]
    return forbidden unless account && (current_account.admin? || is_owner)
    account.update_attributes pick(params, :first_name, :last_name, :email) if account.role == Account::REVIEWER
    if resend
      document = Document.find(params[:document_id])
      account.send_reviewer_instructions(document, current_account)
    end
    json account
  end
  
  private

  def current_document
    @document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end