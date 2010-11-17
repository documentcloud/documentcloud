class ReviewersController < ApplicationController

  def index
    json current_document.reviewers.to_json
  end
  
  def add_reviewer
    account = Account.lookup(params[:email])
    return json(nil, 409) if account and account.id == current_account.id
    if !account
      attributes = {
        :first_name => 'Reviewer',
        :last_name  => 'Name',
        :email      => params[:email],
        :role       => Account::REVIEWER
      }
      attributes = pick(attributes, :first_name, :last_name, :email, :role)
      Rails.logger.info("Attributes; #{attributes}")
      account = current_organization.accounts.create(attributes)
    end
    
    params[:documents].each do |document_id|
      document = Document.find(document_id)
      document.document_reviewers.create(:account => account)
      account.send_reviewer_instructions(document)
    end
    
    json account.to_json
  end
  
  def remove_reviewer
    account = Account.find(params[:account_id])
    params[:documents].each do |document_id|
      document = Document.find(document_id)
      document.document_reviewers.owned_by(account).first.destroy
    end
    json nil
  end


  private

  def current_document
    @document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end