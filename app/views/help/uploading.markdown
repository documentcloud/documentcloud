# Uploading Documents

Most users will be uploading PDFs to DocumentCloud, but we can work with any file type that OpenOffice supports. Microsoft Word documents, RTFs, and OpenDocument files will work just fine.
 
With large files (anything over 10 MB) you might find you get better results and faster uploads if you optimize the size of the document first. If you're on a Mac, you can [use Preview to reduce the size of your file][]. If you've got a copy of Adobe Acrobat, [that works as well][]. If you don't have Acrobat or Preview, our tips on troubleshooting documents might help.

In order to view the list of all the documents you've uploaded, click on the "[Your Documents][]" link at the top left. If you open a project, and you select new documents to upload, those documents will be added to the project automatically.

Uploading Documents in bulk is straightforward. Click the "New Documents" button in the sidebar, and select the files you'd like to upload.

<img src="/images/help/upload_dialog.png" class="full_line" />
 
Before you start the upload, make sure that each document has an appropriate title. Click on the pencil icon to expand the edit details, where you can add a description and source, and set the access level to decide in advance whether the document should stay private, be shared in your newsroom, or be made public immediately. If you have a large number of files to upload at once, click on the link titled: "Apply this Description, Source, and Access Level to All Files", to copy your changes to all of the documents at once.

Once you click the "Upload" button, you'll notice the files uploading one at a time, and the dialog will close when all files have begun their processing.
 
## Suggestions for OCR

If you have access to high quality [OCR][], we recommend that you OCR your document before you upload it to DocumentCloud. 

We're using an OCR program called [Tesseract][]. For an absolutely free tool, it is actually pretty impressive, but you'll get better results with some of the fancier proprietary services like Abbyy or Nuance. Many office photocopiers have built-in OCR these days, so that's another option if you have documents that are difficult to read.
 
# Bulk Uploading via the API

We offer a rudimentary API for bulk uploads. It exposes the same API that we use internally, but wraps it in HTTP Basic Authentication. The documents will be uploaded into the authenticated account. You'll want to post to: `http://documentcloud.org/api/upload.json`
 
Request Params   | &nbsp;
-----------------|----------------
`file`           | (required) the document file itself
`title`          | (required) 
`source`         | (optional)
`description`    | (optional)
`access`         | (optional) one of "`public`", "`private`", "`organization`"
 
You'll definitely want to review your uploaded files and add a source or description once they're up. 
 
Note that we don't yet support SSL uploads, so your username, password and documents are being sent in cleartext. So don't try this on unencrypted wireless (or any network you don't trust).

Still have questions about uploading documents? Don't hesitate to [contact us][].

[use Preview to reduce the size of your file]: http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html
[that works as well]: http://www.ehow.com/how_5874491_decrease-size-pdf.html
[OCR]: http://en.wikipedia.org/wiki/Optical_character_recognition
[Tesseract]: http://code.google.com/p/tesseract-ocr/
