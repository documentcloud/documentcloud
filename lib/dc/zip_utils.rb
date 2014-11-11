require 'zip'

module DC

  # Helper methods for dealing with packaging zip archives, for mixing in to
  # controllers.
  module ZipUtils

    def package(zip_name)
      zipfile = Tempfile.new(["dc",".zip"])
      Zip::File.open(zipfile.path, Zip::File::CREATE) do |zip|
        yield zip
      end
      send_file zipfile.path, :type => 'application/zip', :disposition => 'attachment', :filename => zip_name
      zipfile.close
    end

  end

end
