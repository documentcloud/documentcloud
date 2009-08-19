require 'tmpdir'

module DC
  module Import
    
    # The TextExtractor knows how to pull all of the plain text out of a PDF.
    # This is first attempted by direct text extraction, and if that fails,
    # by OCR.
    #
    # Dependencies:
    # poppler or xpdf for a functional pdftotext command.
    # GraphicsMagick along with tesseract (gm and tesseract commands) for OCR.
    #
    # TODO: This class is going to shell out with the path to the pdf file a 
    # good bit. We need to be *really* confident in the security of the 
    # interpolated path. Also, look into Ruby wrappers for any of the
    # libraries we depend on Ruby/Poppler, RMagick, etc.
    # 
    # TODO: Right now we're returning the string of the full text, but it may
    # not be necessary to ever read the text into memory. Think about just 
    # passing paths around.
    class TextExtractor
      
      TMP_DIR = File.join(Dir.tmpdir, 'dc_text_extractor')
      
      NO_TEXT_DETECTED = /---------\n\Z/
      
      def initialize(pdf_path)
        raise Errno::ENOENT.new(pdf_path) if !File.exists?(pdf_path)
        FileUtils.mkdir_p(TMP_DIR)        if !File.exists?(TMP_DIR)
        
        @pdf_path     = pdf_path
        @pdf_name     = File.basename(pdf_path, '.pdf')
        @target_path  = "#{TMP_DIR}/#{@pdf_name}.txt"
        @tiff_path    = "#{TMP_DIR}/#{@pdf_name}.tif"
      end
      
      def get_text
        contains_text? ? text_from_pdf : text_from_ocr
      end
      
      def get_title
        info = `pdfinfo #{@pdf_path}`
        match = info.match(/Title:\s+(.+?)\n/)
        match ? match[1] : nil
      end
      
      def contains_text?
        font_listing = `pdffonts #{@pdf_path}`
        return !font_listing.match(NO_TEXT_DETECTED)
      end
      
      def text_from_pdf
        `pdftotext -enc UTF-8 #{@pdf_path} #{@target_path}`
        full_text = File.read(@target_path)
        File.unlink(@target_path)
        full_text
      end
      
      # OCR'ing text, uses GraphicsMagick to convert the PDF into a multi-page
      # TIFF, and then Tesseract to OCR. Really quite expensive.
      def text_from_ocr
        `gm convert -density 200x200 -colorspace GRAY #{@pdf_path} #{@tiff_path}`
        `tesseract #{@tiff_path} #{@target_path} -l eng`
        full_text = File.read(@target_path)
        File.unlink(@tiff_path, @target_path)
        full_text
      end
      
    end
    
  end
end