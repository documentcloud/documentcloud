module DC
  module Import
    
    class PDFWrangler
      
      # Number of pages in a parallelized batch.
      DEFAULT_BATCH_SIZE = 5
      
      # Bursts a pdf into individual pages, removing the original file.
      # The double pdftk shuffle fixes the document xrefs.
      def burst(pdf)
        basename = File.basename(pdf, File.extname(pdf))
        `pdftk #{pdf} burst output "#{basename}_%05d.pdf_temp"`
        FileUtils.rm pdf
        pdfs = Dir["*.pdf_temp"]
        pdfs.each {|page| `pdftk #{page} output #{File.basename(page, '.pdf_temp')}.pdf`}
        Dir["*.pdf"]
      end
      
      # Archive a list of PDF pages into TAR archives, grouped by batch_size.
      def archive(pages, batch_size=nil)
        batch_size ||= DEFAULT_BATCH_SIZE
        batches = (pages.length / batch_size.to_f).ceil
        batches.times do |batch_num|
          tar_path = "#{sprintf('%05d', batch_num)}.tar"
          batch_pages = pages[batch_num*batch_size...(batch_num + 1)*batch_size]
          `tar -czf #{tar_path} #{batch_pages.join(' ')}`
        end
        Dir["*.tar"]
      end
      
    end
    
  end
end