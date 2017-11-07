# Troubleshooting Failed Uploads
We're always (with your help) discovering new and different ways to break our document importer. That is a good thing: it is one of the ways you're helping us make DocumentCloud better. 



##Optimizing PDFs
In some cases, resolving a document import issue is as simple as opening the document in Adobe Acrobat or Apple Preview, optimizing it for web use and re-saving it.

**In Adobe Acrobat**

1. Open the PDF and select **"File > Save as Other..."**.
2. Select **"Optimized PDF"** from the menu.
3. Click **"Ok"**.

**In Preview**

1. Open the PDF and choose **"File > Print"**.
2. When the dialog opens, click on the **"PDF"** menu in the lower-left hand corner.
3. Click **"Save as PDF"**.

## Noise in Documents
Occasionally, documents containing government redactions will look like they're covered in a dark gray fog of pixels. GraphicsMagick, which we use to break out images of each page in your document, sometimes smears these redactions across the page. 

Recent updates to Ghostscript seem to have resolved the problem for the most part. **However, if you're still seeing noise in documents, we've found that re-saving a document in Acrobat or Preview can fix the problem.** If that doesn't work, let us know and we'll help you figure it out.
## No Text at All
If you've got high quality text already embedded in your PDF, we don't want to replace your text with a lower-quality version, so when you upload a document, our system looks for a few clues that a document already contains text. 

Sometimes, though, documents give out mixed signals. **If you've got a document that didn't OCR at all, let us know about it.** For one thing, we can get it OCR'd for you. For another, we want to know when our system is making poor assumptions.

## Encrypted or Secured Documents
It is not unheard of for government agencies to release public documents that make use of usage restriction or monitoring capacities of PDFs. **DocumentCloud can process some locked or password protected PDFs, but if we can't unlock a document for you, you may still be able to get around such restrictions.**

You may be able to unlock a document yourself with **qpdf**. If qpdf isn't working for you, see if your operating system or print dialog includes a "Print to file" or "Print to PDF" option. You should be able to "print" a new document which DocumentCloud will be able to work with.

## More Tools

Don't have access to Acrobat or Preview? There's a world of great PDF editors out there (and no shortage of not so great ones) but here are some we've tested:

* **pdftk** [LINK] - If you're comfortable (or would like to get comfortable) working with command line tools, pdftk is a great resource. You can burst one document into many, merge many into one, rotate pages, and more.

* **qpdf** [LINK] - Another excellent command line tool, qpdf will, among other things, decrypt locked PDFs and optimize them for the web (using linearization).

* **PDFill** [LINK] - If you're on Windows and don't have Acrobat already (or just have Acrobat Reader), you might get some mileage out of PDFill's PDF Tools (via Lifehacker). You'll need to cough up $19.99 to get rid of the ads, but even in the free version you'll be able to rotate, merge, split and watermark documents. Their install process is a bit confusing: you have to install their full suite, which includes three different programs. To rotate a document, use PDF Tools, not PDF Editor.

