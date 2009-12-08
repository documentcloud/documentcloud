module DC

  # Helper methods for dealing with packaging zip archives, for mixing in to
  # controllers.
  module ZipUtils

    def package(zip_name)
      Dir.mktmpdir do |temp_dir|
        zipfile = "#{temp_dir}/#{zip_name}"
        Zip::ZipFile.open(zipfile, Zip::ZipFile::CREATE) do |zip|
          yield zip
        end
        # TODO: We can stream, or even better, use X-Accel-Redirect, if we can
        # be sure to clean up the Zip after the fact -- with a cron or equivalent.
        send_file zipfile, :stream => false
      end
    end

  end

end