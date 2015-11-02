namespace :build do

  # Pull in a new build of the Document Viewer.
  task :viewer do
    build_dir = "tmp/build"

    Dir.chdir '../document-viewer'

    FileUtils.rm_r(build_dir) if File.exists?(build_dir)
    sh "jammit -f -o #{build_dir}"
    sh "rm #{build_dir}/*.gz"
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
    sh "cat #{build_dir}/viewer.js #{build_dir}/templates.js > #{build_dir}/viewer_new.js"
    FileUtils.rm_r(["#{build_dir}/viewer.js", "#{build_dir}/templates.js"])
    FileUtils.mv "#{build_dir}/viewer_new.js", "#{build_dir}/viewer.js"
    FileUtils.cp "#{build_dir}/print.css", "../documentcloud/public/viewer/printviewer.css"
    Dir["#{build_dir}/viewer*"].each do |asset|
      FileUtils.cp(asset, "../documentcloud/public/viewer/#{File.basename(asset)}")
    end

    FileUtils.rm_r(build_dir) if File.exists?(build_dir) # Clean up tmp
  end

  namespace :embed do

    task :page do
      page_embed_dir = 'public/embed/page'

      FileUtils.rm_r(page_embed_dir) if File.exists?(page_embed_dir)
      FileUtils.mkdir(page_embed_dir)
      FileUtils.cp_r(Dir.glob("public/javascripts/vendor/documentcloud-pages/dist/*"), page_embed_dir)
      FileUtils.cp_r(Dir.glob("public/javascripts/vendor/documentcloud-pages/src/css/vendor/fontello/font"), page_embed_dir)
      # TODO: Configure S3/CloudFront to serve gzipped versions; until then, nix
      sh "rm #{page_embed_dir}/*.gz"
    end

    task :note do
      note_embed_dir = 'public/note_embed'

      FileUtils.rm_r(note_embed_dir) if File.exists?(note_embed_dir)
      FileUtils.mkdir(note_embed_dir)
      FileUtils.cp_r(Dir.glob("public/javascripts/vendor/documentcloud-notes/dist/*"), note_embed_dir)
      # TODO: Configure S3/CloudFront to serve gzipped versions; until then, nix
      sh "rm #{note_embed_dir}/*.gz"
    end

    task :search do
      search_embed_dir = "public/search_embed"
      build_dir        = "tmp/build"

      FileUtils.rm_r(build_dir) if File.exists?(build_dir)
      sh "jammit -f -o #{build_dir} -c config/search_embed_assets.yml"
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

      FileUtils.rm_r(build_dir) if File.exists?(build_dir) # Clean up tmp
    end

    task :all do
      invoke "build:embed:page"
      invoke "build:embed:note"
      invoke "build:embed:search"
    end

  end

  task :note_embed do
    puts "DEPRECATED. Use `build:embed:note` instead."
  end

  task :search_embed do
    puts "DEPRECATED. Use `build:embed:search` instead."
  end

end
