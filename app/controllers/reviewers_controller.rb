class ReviewersController < ApplicationController

  def index
    json current_document.reviewers.to_json
  end

  def create
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
      Rails.logger.info("Account 1: #{account.id}")
    end
    
    current_document.document_reviewers.create(:account => account)
    account.send_reviewer_instructions(current_document)
    json account.to_json
  end

  def destroy
    account = Account.find(params[:id])
    current_document.document_reviewers.owned_by(account).first.destroy
    json nil
  end


  private

  def current_document
    @document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end