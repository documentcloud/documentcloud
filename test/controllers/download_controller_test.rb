require 'test_helper'

class DownloadControllerTest < ActionController::TestCase

  # RubyZip has a seemingly convenient Zip::ZipFile.open_buffer method - too bad it's totally borked
  # Various internal methods want the String passed in to have a path, monkey patching that in didn't work either
  # I would report a bug/pull request on it, but looks like they're in the middle of a pretty major re-write
  # Plus it doesn't like passing a Tempfile, since it's not a direct instance of IO (it uses DelegateClass)
  def zip_from_response( response )
    Tempfile.open( 'testzip.zip', :encoding=>'binary' ) do | tf |
      tf.write response.body
      tf.flush
      File.open( tf.path ) do | zip_file |
        Zip::File.open( zip_file ) do | zf |
          yield zf
        end
      end
    end
  end

  it "downloads text" do
    get :bulk_download, :args=>"#{doc.id}/document_text"
    assert_response :success

    zip_from_response( response ) do | zf |
      assert_equal doc.combined_page_text, zf.read( "#{doc.slug}.txt" )
    end
  end

  it "sends the viewer" do
    get :bulk_download, :args=>"#{doc.id}/document_viewer"
    assert_response :success
    zip_from_response( response ) do | zf |
      assert_match "<title>#{doc.title}</title>", zf.read( "#{doc.slug}.html" )
    end
  end


end
