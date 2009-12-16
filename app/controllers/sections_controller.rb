class SectionsController < ApplicationController

  before_filter :login_required

  def set
    return json(nil) if !sections || sections.empty?
    current_document.sections.destroy_all
    sections.each {|s| current_document.sections.create(s) }
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