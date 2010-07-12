# Uploading Documents

Most users will be uploading PDFs to DocumentCloud, but we can work with any file type that OpenOffice.org supports. Microsoft Word documents, RTFs, and OpenOffice files will work just fine.
 
With large files (anything over 10 MB) you might find you get better results and faster uploads if you optimize the size of the document first. If you're on a Mac, you can [use Preview to reduce the size of your file][]. If you've got a copy of Adobe Acrobat, [that works as well][]. If you don't have Acrobat or Preview, our tips on troubleshooting documents might help.

<div class="minibutton float_right plus new_document" style="margin: 0 0 20px 20px;" onclick="javascript:dc.app.uploader.open();"><div class="icon white_plus"></div>New Document</div>

Uploading Documents is straightforward. Open the Upload dialog by clicking on the "[New Document][]" button in the sidebar.
 
All documents you upload are available by clicking on the "[Your Documents][]" link at the top left. If you've started a project, and you click on "[New Document][]" while you have that project open, your document will be added to the project automatically. 
 
Before you start the upload, you can enter a title for the document, as well as a source and description &mdash; all of which will appear when the document is found in search results. You can also decide in advance whether the document should stay private, be shared in your newsroom, or be made public immediately.
 
# OCR

If you have access to high quality [OCR][], we recommend that you OCR your document before you upload it to DocumentCloud. 

We're using an OCR program called [Tesseract][]. For an absolutely free tool, it is actually pretty impressive, but you'll get better results with some of the fancier proprietary services like Abbyy or Nuance. Many office photocopiers have built-in OCR these days, so that's another option if you have documents that are difficult to read.
 
# Bulk Uploading via the API

We offer a rudimentary API for bulk uploads. It exposes the same API that we use internally, but wraps it in HTTP Basic Authentication. The documents will be uploaded into the authenticated account. You'll want to post to: `http://documentcloud.org/api/upload.json`
 
Request Params | &nbsp;
---------------|----------------
file           | (required) the document file itself
title          | (required) 
source         | (optional)
description    | (optional)
access         | (optional) one of "public", "private", "organization"
 
You'll definitely want to review your uploaded files and add a source or description once they're up. 
 
Note that we don't yet support SSL uploads, so your username, password and documents are being sent in cleartext. So don't try this on unencrypted wireless (or any network you don't trust).

Still have questions about uploading documents? Don't hesitate to [contact us][].

[contact us]: javascript:dc.app.workspace.help.openContactDialog()
[use Preview to reduce the size of your file]: http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html
[that works as well]: http://www.ehow.com/how_5874491_decrease-size-pdf.html
[New Document]: javascript:dc.app.uploader.open()
[Your Documents]: javascript:Accounts.current().openDocuments()
[OCR]: http://en.wikipedia.org/wiki/Optical_character_recognition
[Tesseract]: http://code.google.com/p/tesseract-ocr/