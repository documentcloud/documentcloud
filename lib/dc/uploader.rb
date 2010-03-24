require 'cgi'

module DC

  # Proof of concept of the DocumentCloud upload API.
  class Uploader

    # The location of the DocumentCloud API.
    API = 'www.documentcloud.org/api/upload.json'

    # Initialize the uploader with the document file, it's title, and the
    # optional access, source, and description...
    def initialize(file, attributes)
      @file, @attributes = file, attributes
      raise "Documents must have a file and title to be uploaded" unless @file && @attributes[:title]
    end

    def upload(username, password)
      username, password = CGI.escape(username), CGI.escape(password)
      attrs = @attributes.map {|key, value| "-F #{key}=\"#{value.gsub('"', '\\\\"')}\"" }.join(' ')
      url   = "http://#{username}:#{password}@#{API}"
      puts cmd = "curl -F file=@#{@file} #{attrs} #{url}"
      system cmd
    end

  end

end