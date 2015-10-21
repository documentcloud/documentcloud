# Document Modification

We don't tend to think of modifying source documents as something a responsible journalist would do, but there are absolutely times when you need to. Whether you're trying to protect the privacy of a minor by redacting personally identifying information from a foster care incident report, reorganizing a collection of letters or inserting a page that wasn't properly scanned, journalists sometimes need to rework source documents to ready them for publication. That's why DocumentCloud provides tools for modifying documents. Open any document that needs correction, and look in the sidebar for specific tools.

## <span id="redactions">Redacting Documents</span>

Not everything is appropriate for publication. [Reports from a state foster care agency](http://media.apps.chicagotribune.com/docs/ct-met-dcfs-letters.html) might illustrate a story well, but such documents are also usually full of sensitive information like the full names of minors or other personally identifying information. We expect newsrooms to use their own policies and judgement in determining what is and is not suitable for publication.

When you do need to redact passages from a document, open the document in DocumentCloud and select **Redact Document** in the sidebar. Draw a redaction just as you'd draw an annotation: set the cursor at one corner and drag until you've drawn your rectangle over the full passage.

<img alt="screenshot of redaction process" src="/images/help/redact.jpg" class="full_line" />

When you save your redactions, DocumentCloud will render new images and text information for each altered page and re-extract the entity information for the redacted document. This means [any corrections you have made to the text of a page](#texttools) will be lost when you save your redactions, though DocumentCloud won't touch pages you haven't redacted.

The accompanying PDF of your document will also be rebuilt: the original page will be replaced with the redacted version. No trace of the redacted passage should remain in the document. Please do check your work, however!

## <span id="pagetools">Page Tools</span>

Within the pages tab of any document that you have permission to edit, you'll find page manipulation tools in the sidebar on the right. As you save changes, the document window will close so DocumentCloud can rebuild your document. Depending on the size of the document and the number of other jobs DocumentCloud is handling, this can take a while. Any changes to a document will also be applied to the original PDF file.

 * Select **Insert/Replace Pages** and click the space between any two pages to insert pages. Select any single page to replace that page. Hold the shift key and select multiple pages to replace an entire section of the document. When you're ready to proceed, click the "Upload Pages" button to choose a file from your computer to insert or replace the chosen pages.

<img alt="screenshot of insert process" src="/images/help/insert.jpg" class="full_line" />

 * Select **Remove Pages** and click once on each page that should be removed from the document. Click the page again to pull it out of the "remove" queue. Use the "Remove Pages" button to save your work.

 * To reorganize a document, click **Reorder Pages** and drag and drop pages into their new locations. Use "Save Page Order" to save your work.

## <span id="texttools">Text Tools</span>

Need to clean up OCR gibberish? Edit the text that appears in DocumentCloud's text tab with the **Edit Page Text** option. As you make changes to individual pages, you'll see a thumbnail in your activity tray. Need to undo your edits? Revert the text of any page by hovering over it in the activity tray and clicking on the **(x)** icon.

<img alt="screenshot of text editing process" src="/images/help/text.jpg" class="full_line" />

Use the back and forward arrows at the top of the sidebar to page through any document. When you click the "Save Text" button, DocumentCloud will store your changes and update the search index and entity list for that document. Changes made with **Edit Page Text** will not alter the original PDF.

Use **Reprocess Text** to take advantage of improvements to DocumentCloud's text processing tools. As we work, DocumentCloud is continually improving the tools we provide to users. If we [improve the quality of our OCR][] tools, you can try processing an old document anew for better results. By default, DocumentCloud tries to use the text content embedded in the PDF file, if available. If you know that this text is incorrect, and you would prefer to have DocumentCloud use Tesseract to extract the text via optical character recognition, choose the **Force OCR** option.

Still have questions about document modification? Don't hesitate to [contact us][].


[improve the quality of our OCR]: https://blog.documentcloud.org/blog/2010/11/improving-the-quality-of-ocr/
[contact us]: javascript:dc.ui.Dialog.contact()
