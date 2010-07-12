# Troubleshooting Failed Document Uploads

We're always (with your help) discovering new and different ways to break our document importer. That is a good thing: it is one of the ways you're helping us make DocumentCloud better. In some cases, resolving a document import issue is as simple as opening the document in Adobe Acrobat or Apple Preview, optimizing it for web use and re-saving it.

In Preview, open the PDF and choose "File > Save As". Choose "Reduce File Size" from the "Quartz Filter" menu, and click "Save". If that doesn't work, another option is "File > Print", and then, clicking on the "PDF" menu in the lower-left hand corner, using "Save as PDF".

In Acrobat, open the PDF and choose "Advanced > PDF Optimizer". You'll see a window with a list of categories of optimizations on the left. Click through the list, and make sure that all of the possible optimizations are checked. When you're ready, click "Ok" to save the PDF.

![PDF Optimizer][]

&nbsp;

# Noise in Documents

Ever so very occasionally, we find that documents containing government redactions will look like they're covered in a dark gray fog of pixels. GraphicsMagick, which we use to break out images of each page in your document, seems to sometimes smear these redactions across the page. We've found that re-saving a document in Acrobat or Preview can fix this. If that isn't working, [let us know][] and we'll help you figure it out.
 
# No Text At All

If you've got high quality text already embedded in your PDF, we don't want to replace your text with a lower-quality version, so when you upload a document, our system looks for a few clues that a document already contains text. Sometimes, though, documents give out mixed signals. If you've got a document that didn't OCR at all, let us know about it. For one thing, we can get it OCR'd for you. For another, we want to know when our system is making poor assumptions.
 
# Encrypted or Secured Documents 

It is not unheard of for government agencies to release public documents that make use of usage restriction or monitoring capacities of PDFs. DocumentCloud can process some locked or password protected PDFs, but not all of them. If your operating system or print dialog includes a "Print to file" or "Print to PDF" option, you should be able to print a new document which DocumentCloud will be able to work with.

Still having trouble with a document? Don't hesitate to [contact us][].

[contact us]: javascript:dc.app.workspace.help.openContactDialog()
[Reduce File Size]: /images/help/reduce_file_size.jpg
[PDF Optimizer]: /images/help/pdf_optimizer.jpg
[let us know]: javascript:dc.app.workspace.help.openContactDialog()
