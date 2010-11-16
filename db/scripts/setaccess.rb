asset_store = DC::Store::AssetStore.new
total = Document.count
docs = Document.find(:all, :conditions => ['id > 2866'], :order => 'id ASC'); nil
threads = []
done = 2866
5.times do
  threads << Thread.new do
    while doc = docs.shift
      begin
        done += 1
        puts "#{done}/#{total}: #{doc.title} (#{doc.id})";
        asset_store.set_access(doc, doc.access) 
      rescue Exception => e
        puts e
      end
    end
  end
end

threads.each {|t| t.join }
