class DownloadController < ApplicationController
  include DC::ZipUtils

  layout nil

  # TODO: Access control this, but not yet.
  def bulk_download
    @documents = Document.accessible(current_account, current_organization).find_all_by_id(params[:args][0...-1])
    case params[:args].last
    when 'document_pdfs'    then send_pdfs
    when 'document_text'    then send_text
    when 'document_viewer'  then send_viewer
    else not_found
    end
  end


  private

  # TODO: Figure out a more efficient way to package PDFs.
  def send_pdfs
    package("#{package_name}.zip") do |zip|
      @documents.each do |doc|
        zip.get_output_stream("#{doc.slug}.pdf") {|f| f.write(asset_store.read_pdf(doc)) }
      end
    end
  end

  def send_text
    package("#{package_name}.zip") do |zip|
      @documents.each do |doc|
        zip.get_output_stream("#{doc.slug}.txt") {|f| f.write(doc.text) }
      end
    end
  end

  def send_viewer
    assets = Dir["#{Rails.root}/public/viewer/**/*"]
    package("#{package_name}.zip") do |zip|
      assets.each {|asset| zip.add("viewer/#{File.basename(asset)}", asset) }
      @documents.each do |doc|
        @current_document = doc
        html = ERB.new(File.read("#{Rails.root}/app/views/documents/show.html.erb")).result(binding)
        html.gsub!(/\="\/viewer\//, '="viewer/')
        html.gsub!(/\="\/stylesheets\/pages\//, '="viewer/')
        zip.get_output_stream("#{doc.slug}.html") {|f| f.write(html) }
      end
    end
  end

  def package_name
    @documents.length == 1 ? @documents.first.slug : 'document_viewers'
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end

end