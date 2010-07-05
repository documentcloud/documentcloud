# Uploading Documents

Most users will be uploading PDFs to DocumentCloud, but we can work with any file type that OpenOffice.org supports. So MS Word documents and OpenOffice files will work just fine.
 
With very large files (anything over 10 MB is large) you might find you get better results if you minimize the document first. If you're on a Mac, you can [use Preview to reduce the size of your file](http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html). If you've got a copy of Adobe Acrobat, [that works too](http://www.ehow.com/how_5874491_decrease-size-pdf.html). If you don't have Acrobat or Preview, our tips on troubleshooting documents might help.
 
**IMAGE**

Uploading Documents is straightforward. Look for the "Add Document" button at the lower left to open the Upload dialog.
 
All documents you upload will be available in your "Uploaded Documents" project, but if you start a new project and "add document" while you have that project open, your document will also be added to that project. 
 
While you're uploading a document, you can decide whether it should stay private, be shared in your newsroom, or be made public immediately. You can also give the document a title, and provide some information about your source for the document.
 
 
## Bulk Uploading via the API

We do offer a rudimentary API for batch uploads. It exposes the same API that we use internally for document uploads,  but wraps it in HTTP Basic Authentication. The documents will be uploaded into the authenticated account. You'll want to post to: http://documentcloud.org/api/upload.json
 
Request Params:
 * file: (required) the path to the actual document
 * title: (required)
 * source: (optional)
 * description: (optional)
 * access: (optional) one of "public", "private", "organization"
 
You'll definitely want to review your uploaded files and add a source or description once they're up. 
 
Note that we can't yet support SSL uploads, so your username, password and documents are being sent in cleartext. So don't try this on unencrypted wireless (or any network you don't trust).