namespace :build do

  # Pull in a new build of the Document Viewer.
  task :viewer do

    Dir.chdir '../document-viewer'

    FileUtils.rm_r('build') if File.exists?('build')
    sh "jammit -f -o build"
    sh "rm build/*.gz"
    Dir['build/*.css'].each do |css_file|
      File.open(css_file, 'r+') do |file|
        css = file.read
        css.gsub!(/(\.\.\/)+images/, 'images')
        file.rewind
        file.write(css)
        file.truncate(css.length)
      end
    end
    FileUtils.cp_r('public/images', 'build/images')

    # Export back to DocumentCloud
    FileUtils.cp_r('build/images', '../documentcloud/public/viewer')
    `cat build/viewer.js build/templates.js > build/viewer_new.js`
    FileUtils.rm_r(['build/viewer.js', 'build/templates.js'])
    FileUtils.mv 'build/viewer_new.js', 'build/viewer.js'
    FileUtils.cp 'build/print.css', "../documentcloud/public/viewer/printviewer.css"
    Dir['build/viewer*'].each do |asset|
      FileUtils.cp(asset, "../documentcloud/public/viewer/#{File.basename(asset)}")
    end
    FileUtils.rm_r('build') if File.exists?('build')

  end
  
  task :note_embed do
    FileUtils.cp_r(Dir.glob("public/javascripts/vendor/documentcloud-notes/dist/*"), "public/note_embed")
  end

  task :search_embed do
    FileUtils.rm_r('build') if File.exists?('build')
    sh "jammit -f -o build -c config/search_embed_assets.yml"

    Dir['build/*.css'].each do |css_file|
      File.open(css_file, 'r+') do |file|
        css = file.read
        css.gsub!("/images/search_embed", 'images')
        file.rewind
        file.write(css)
        file.truncate(css.length)
      end
    end
    FileUtils.cp_r("public/images/search_embed", 'build/images') if File.exists?("public/images/search_embed")

    FileUtils.rm_r("public/search_embed") if File.exists?("public/search_embed")
    FileUtils.cp_r('build', "public/search_embed")

    FileUtils.rm_r('build') if File.exists?('build')
  end

end
