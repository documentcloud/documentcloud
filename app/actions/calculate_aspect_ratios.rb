class CalculateAspectRatios < CloudCrowd::Action
  
  def process
    errors = []

    page_numbers = (1..document.page_count)
    @page_aspect_ratios = page_numbers.map do |page_number|
      path = document.page_image_path(page_number, 'small')
      filename = File.basename(path)
      begin
        File.open(filename, 'wb'){ |file| file << asset_store.read(path) }
        cmd = %(gm identify #{filename} | egrep -o "[[:digit:]]+x[[:digit:]]+")
        width, height = `#{cmd}`.split("x").map(&:to_f)
        width / height
      rescue Exception => e
        errors.push({params: options.merge({page_number: page_number}), error: e})
        0
      end
    end
    
    save_page_aspect_ratios!
    errors
  end
  
  private
  def save_page_aspect_ratios!
    ids = document.pages.order(:page_number).pluck(:id)
    
    query_template = <<-QUERY
    UPDATE pages 
      SET aspect_ratio = input.aspect_ratio
      FROM (SELECT unnest(ARRAY[?]) as id, unnest(ARRAY[?]) as aspect_ratio) AS input
      WHERE pages.id = input.id::int
    QUERY
    query = Page.send(:replace_bind_variables, query_template, [ids, @page_aspect_ratios])
    Page.connection.execute(query)
  end
  
  def document
    @document ||= Document.find(options['id'])
  end

  def asset_store
    @asset_store ||= DC::Store::AssetStore.new
  end
  
end
