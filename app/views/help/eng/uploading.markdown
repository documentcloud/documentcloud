# Uploading documents

As a DocumentCloud user, you'll want to build a collection of files to research, analyze, annotate and publish with our embeds. Fortunately, uploading files -- whether you have a handful or several thousand -- is easy.

## Contents

* Uploading:
  * [Upload via the Workspace](#upload-workspace)
  * [Upload via the API](#upload-api)
* Details and Options:
  * [OCR Languages](#ocr-languages)
  * [File Formats](#file-formats)
  * [File Size](#file-size)

<a name="upload-workspace"></a>
## Upload Via the Workspace

There are two ways to upload in the workspace:

* Drag and drop the documents onto the workspace itself.
* Alternately, click the "New Documents" button in the sidebar and select the files you'd like to upload. In Windows, hold down the `ctrl` key to select more than one document. On a Mac, hold down `command`. *Note: multiple document upload is not supported in older versions of Internet Explorer.*

<img src="/images/help/upload_dialog.png" class="full_line" />

The uploader will suggest a title for your document based on its file name. You can edit the title before you continue, or you can edit the title plus other metadata after the document is uploaded. Click the pencil icon to add a description and source for each document and set the access level (default is private). If the files you are uploading should share a source and description, click "Apply to All Files."

When you're ready, click "Upload." The dialog will close when all files have been uploaded. Before you can work with them, however, DocumentCloud must process the documents for the document viewer. The amount of time required to process a document varies based on its size, its type, and the current amount of platform activity.

To be notified by email when your documents are finished, click the checkbox. If you plan to upload many large documents at once, let us know so we can ensure there's enough computing resources available.

To view all the documents you've uploaded, click on the "[Your Documents][]" link at the top left.

<a name="upload-api"></a>
## Upload Via the API

Users who want to upload many hundreds or thousands of documents or automate document uploads may want to consider using the [DocumentCloud API][]. The `upload.json` [method][] provides for passing in file name, project id and numerous other parameters with the file itself. It also allows for uploads directly from a URL.

<a name="ocr-languages"></a>
## OCR (Optical Character Recognition) Languages

If your file has text embedded, DocumentCloud extracts and saves it. If not (as with an image file or a PDF of a scanned document), DocumentCloud uses optical character recognition ([OCR][]) software to attempt to identify the text. For this, our platform relies upon the open-source [Tesseract][] library.

Through Tesseract, DocumentCloud currently supports more than 20 languages for OCR, including Arabic, Spanish and Russian. You can select a default language under the "Accounts" tab in the workspace. Choose a language under the "New Documents" drop-down menu.

<a name="file-formats"></a>
## File Formats

Most DocumentCloud users work with PDFs, but our software can take any file type that [LibreOffice][] supports. This includes Microsoft Word, Excel and PowerPoint; Rich Text Files; and various image files including TIFF, PNG, GIF and JPEG.

Upon upload, all non-PDF files are converted to PDF for use in DocumentCloud.

<a name="file-size"></a>
## File Size

The maximum file size for an upload to DocumentCloud is 400 MB. However, files that large are difficult to process, and you will likely get better results if you optimize large documents (anything over 10 MB) before you upload them. On a Mac, [use Preview to reduce the size of your file][]. Adobe Acrobat [works as well][]. Don't have Acrobat or Preview? Take a look at our tips on [troubleshooting documents][] for more resources.


Still have questions about uploading documents? Don't hesitate to [contact us][].

[LibreOffice]: http://www.libreoffice.org/
[use Preview to reduce the size of your file]: http://www.ehow.com/how_4499823_reduce-file-size-pdf-using.html
[works as well]: http://www.ehow.com/how_5874491_decrease-size-pdf.html
[OCR]: http://en.wikipedia.org/wiki/Optical_character_recognition
[Tesseract]: http://code.google.com/p/tesseract-ocr/
[contact us]: javascript:dc.ui.Dialog.contact()
[troubleshooting documents]: /help/troubleshooting
[DocumentCloud API]: /help/api
[method]: /help/api#upload-documents
[Your Documents]: javascript:Accounts.current().openDocuments()
