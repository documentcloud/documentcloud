module DC
  module Import

    # The TextExtractor knows how to pull all of the plain text out of a PDF.
    # This is first attempted by direct text extraction, and if that fails,
    # by OCR.
    #
    # Dependencies:
    # poppler or xpdf for a functional pdftotext command.
    # GraphicsMagick along with tesseract (gm and tesseract commands) for OCR.
    class TextExtractor

      TMP_DIR = File.join(Dir.tmpdir, 'dc_text_extractor')

      NO_TEXT_DETECTED = /---------\n\Z/

      def initialize(pdf_path)
        raise Errno::ENOENT.new(pdf_path) unless pdf_path && File.exists?(pdf_path)
        FileUtils.mkdir_p(TMP_DIR)        unless File.exists?(TMP_DIR)

        @pdf_path   = pdf_path
        @pdf_name   = File.basename(pdf_path, '.pdf')
        @base_path  = "#{TMP_DIR}/#{@pdf_name}"
        @plain_path = "#{@base_path}-plain.txt"
        @text_path  = "#{@base_path}.txt"
        @tiff_path  = "#{@base_path}.tif"
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
        `pdftotext -enc UTF-8 #{@pdf_path} #{@plain_path}`
        `iconv -f UTF-8 -t UTF-8//TRANSLIT//IGNORE < #{@plain_path} > #{@text_path}`
        full_text = File.read(@text_path)
        File.unlink(@text_path)
        full_text
      end

      # OCR'ing text, uses GraphicsMagick to convert the PDF into a multi-page
      # TIFF, and then Tesseract to OCR. Really quite expensive.
      # If Ocropus ever stabilizes, replace raw Tesseract with that instead.
      def text_from_ocr
        system "gm convert -density 200x200 -colorspace GRAY #{@pdf_path} #{@tiff_path}"
        system "tesseract #{@tiff_path} #{@base_path} -l eng"
        full_text = File.read(@text_path)
        File.unlink(@tiff_path, @text_path)
        full_text
      end

    end

  end
end