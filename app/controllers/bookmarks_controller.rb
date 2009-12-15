class BookmarksController < ApplicationController

  before_filter :login_required

  def index
    json 'bookmarks' => current_account.bookmarks.alphabetical
  end

  def show
    redirect_to current_bookmark.document_viewer_url
  end

  def create
    json current_account.bookmarks.create(pick_params(:title, :document_id, :page_number))
  end

  def destroy
    current_bookmark.destroy
    json nil
  end


  private

  def current_bookmark
    current_account.bookmarks.find(params[:id])
  end

end