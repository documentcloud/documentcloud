namespace :build do

  namespace :embed do

    task :viewer do
      puts "Building viewer..."

      # Navigate up and over to the `document-viewer` repo
      # TODO: Stop doing this!
      Dir.chdir '../document-viewer'

      build_dir = "tmp"
      FileUtils.rm_r(build_dir) if File.exists?(build_dir)

      `jammit -f -o #{build_dir}`
      Dir["#{build_dir}/*.css"].each do |css_file|
        File.open(css_file, 'r+') do |file|
          css = file.read
          css.gsub!(/(\.\.\/)+images/, 'images')
          file.rewind
          file.write(css)
          file.truncate(css.length)
        end
      end
      FileUtils.cp_r("public/images", "#{build_dir}/images")

      # Export back to DocumentCloud
      FileUtils.cp_r("#{build_dir}/images", "../documentcloud/public/viewer")
      `cat #{build_dir}/viewer.js #{build_dir}/templates.js > #{build_dir}/viewer_new.js`
      FileUtils.rm_r(["#{build_dir}/viewer.js", "#{build_dir}/templates.js"])
      FileUtils.mv("#{build_dir}/viewer_new.js", "#{build_dir}/viewer.js")
      FileUtils.cp("#{build_dir}/print.css", "../documentcloud/public/viewer/printviewer.css")
      Dir["#{build_dir}/viewer*"].each do |asset|
        FileUtils.cp(asset, "../documentcloud/public/viewer/#{File.basename(asset)}")
      end

      # Clean up temp build directory
      FileUtils.rm_r(build_dir) if File.exists?(build_dir)

      Dir.chdir '../documentcloud'

      puts "Done building viewer"
    end

    task :page  do
      puts "Building page embed..."

      vendor_dir     = "public/javascripts/vendor/documentcloud-pages"
      page_embed_dir = "public/embed/page"

      FileUtils.rm_r(page_embed_dir) if File.exists?(page_embed_dir)
      FileUtils.mkdir(page_embed_dir)
      FileUtils.cp_r(Dir.glob("#{vendor_dir}/dist/*"), page_embed_dir)
      FileUtils.cp_r(Dir.glob("#{vendor_dir}/src/css/vendor/fontello/font"), page_embed_dir)

      `cat #{vendor_dir}/src/js/config/config.js.erb #{page_embed_dir}/enhance.js > app/views/embed/enhance.js.erb`
      FileUtils.rm(["#{page_embed_dir}/enhance.js"])

      puts "Done building page embed"
    end

    task :note do
      puts "Building note embed..."

      note_embed_dir = 'public/note_embed'

      FileUtils.rm_r(note_embed_dir) if File.exists?(note_embed_dir)
      FileUtils.mkdir(note_embed_dir)

      FileUtils.cp_r(Dir.glob("public/javascripts/vendor/documentcloud-notes/dist/*"), note_embed_dir)

      puts "Done building note embed"
    end

    task :search do
      puts "Building search embed..."

      search_embed_dir = "public/search_embed"

      build_dir        = "tmp/build"
      FileUtils.rm_r(build_dir) if File.exists?(build_dir)

      `jammit -f -o #{build_dir} -c config/search_embed_assets.yml`
      Dir["#{build_dir}/*.css"].each do |css_file|
        File.open(css_file, 'r+') do |file|
          css = file.read
          css.gsub!("/images/search_embed", 'images')
          file.rewind
          file.write(css)
          file.truncate(css.length)
        end
      end
      FileUtils.cp_r("public/images/search_embed", "#{build_dir}/images") if File.exists?("public/images/search_embed")

      FileUtils.rm_r(search_embed_dir) if File.exists?(search_embed_dir)
      FileUtils.cp_r(build_dir, search_embed_dir)

      # Clean up temp build directory
      FileUtils.rm_r(build_dir) if File.exists?(build_dir)

      puts "Done building search embed"
    end

    task :all do
      invoke "build:embed:viewer"
      invoke "build:embed:page"
      invoke "build:embed:note"
      invoke "build:embed:search"
    end

  end

  # Notices for old task names
  task :viewer do puts       "REMOVED: Use `build:embed:viewer` instead." end
  task :note_embed do puts   "REMOVED: Use `build:embed:note` instead." end
  task :search_embed do puts "REMOVED: Use `build:embed:search` instead." end

end
