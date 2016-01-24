require File.join(File.dirname(__FILE__), 'support', 'document_action')

class CalculateAspectRatios < DocumentAction
  
  def process
    errors = []
    document = Document.find(input)
    @page_aspect_ratios = (1..document.page_count).map do |page_number|
      path = document.page_image_path(page_number, 'small')
      filename = File.basename(path)
      begin
        File.open(filename, 'wb'){ |file| file << asset_store.read(path) }
        cmd = %(gm identify #{filename} | egrep -o "[[:digit:]]+x[[:digit:]]+")
        width, height = `#{cmd}`.split("x").map(&:to_f)
        width / height
      rescue Exception => e
        params = options.merge({page_number: page_number})
        errors.push(params)
        LifecycleMailer.exception_notification(e,params).deliver_now
        0
      end
    end
    
    save_page_aspect_ratios!
    errors
  end
  
  def save_page_aspect_ratios!
    ids = document.pages.order(:page_number).pluck(:id)
    
    query_template = <<-QUERY
    UPDATE pages 
      SET aspect_ratio = input.aspect_ratio
      FROM (SELECT unnest(ARRAY[?]) as id, unnest(ARRAY[?]) as aspect_ratio) AS input
      WHERE pages.id = input.id
    QUERY
    query = Page.send(:replace_bind_variables, query_template, [ids, @page_aspect_ratios])
    Page.connection.execute(query)
  end
  
end

__END__
operator = Account.lookup(email)
Document.find_each do |document|
  job = document.processing_jobs.new( 
    action: 'calculate_aspect_ratios', 
    title: 'calculate_aspect_ratios', 
    options: {id: document.id},
    account_id: operator.id
  )
  job.queue
end
