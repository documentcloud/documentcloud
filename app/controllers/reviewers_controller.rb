class ReviewersController < ApplicationController

  def index
    json current_document.reviewers.to_json
  end

  def create
    account = Account.lookup(pick(params, :email)[:email])
    return json(nil, 409) if account.id == current_account.id
    if !account
      attributes = {
        :first_name => 'Reviewer',
        :last_name  => '',
        :email      => params[:email],
        :role       => Account::REVIEWER
      }
      account = current_organization.accounts.create(attributes)
    end
    json account.to_json
  end

  def destroy
    account = Account.find(params[:id])
    current_document.reviewers.remove_collaborator account
    json nil
  end


  private

  def current_document
    @document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end