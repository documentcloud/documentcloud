class SectionsController < ApplicationController

  before_action :login_required
  before_action :read_only_error if read_only?

  def set
    return bad_request unless sections
    doc = current_document
    return forbidden unless current_account.allowed_to_edit?(doc)
    doc.sections.destroy_all
    sections.each {|s| doc.sections.create(pick(s, :title, :page_number)) }
    expire_pages doc.cache_paths if doc.cacheable?
    json nil
  end

  private

  def sections
    @sections ||= params[:sections] && JSON.parse(params[:sections])
  end

  def current_document
    @current_document ||= Document.accessible(current_account, current_organization).find(params[:document_id])
  end

end