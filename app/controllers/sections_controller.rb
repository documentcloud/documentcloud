class SectionsController < ApplicationController

  before_filter :login_required

  def set
    return json(nil) unless sections
    doc = current_document
    return json(nil, 403) unless current_account.allowed_to_edit?(doc)
    doc.sections.destroy_all
    sections.each {|s| doc.sections.create(pick(s, :title, :page_number)) }
    expire_page doc.canonical_cache_path if doc.cacheable?
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