# Annotate Documents: Public, Private, and Draft Notes
![Annotations][]

DocumentCloud supports both private and public notes. Public notes are visible to anyone who has access to the  document, while private notes are only ever visible to their author. Public notes may also be saved as drafts: draft notes are visible to anyone with the privileges necessary to annotate a document, including [reviewers and collaborators](collaboration), but they won't be published with the document.

Annotate any document by opening and selecting either "Add a public note" or "Add a private note." Your cursor should change to crosshairs: click and drag to select the area you'd like to highlight. When you release the cursor, you will be able to add and save your note.

To annotate a page *in general* rather than just a region of it, hover the annotation crosshair in the gutter between pages. A note tab and dotted line will appear &mdash; click near the line to create a note that sits between the pages.

<img alt="" src="/images/help/add_page_note.jpg" class="full_line" />

It is not possible to resize a note. Instead, copy the contents, delete the existing note, and redraw it.

![Notes Link][]

Notes on a document are available in the workspace as well as in the open document. Use the "notes" link underneath any document thumbnail to display *all* of the document's notes in the workspace. Each note's title links to that note in the document viewer. If you have permission to edit a document, you can also edit the notes from inside the workspace itself. If you're changing notes in the workspace and in the document viewer simultaneously, you may need to refresh the page to see the latest changes.

## <span id="markup">Markup and HTML in Notes</span>

Note bodies can contain a limited subset of HTML and attributes.  The table below lists some commonly used elements and attributes.  You can find a full list beneath the table.

Element                                  | Description | Attributes
-----------------------------------------|------------------------------------------|-----------
[&lt;a&gt;][a]                           | creates a hyperlink                      | href
[&lt;img&gt;][img]                       | displays an image                        | src, width, height, alt, align
[&lt;br/&gt;][br]                        | inserts a line break                     | –
[&lt;em&gt;][em], [&lt;i&gt;][i]         | emphasizes/italicizes text               | –
[&lt;strong&gt;][strong], [&lt;b&gt;][b] | bolds text                               | –
[&lt;u&gt;][u]                           | underlines text                          | –
[&lt;blockquote&gt;][blockquote]         | offsets text as a quote                  | –
[&lt;table&gt;][table]                   | creates a table into which rows (tr elements) are inserted | summary, width
[&lt;tr&gt;][tr]                         | creates a table row to hold table data (td elements) and table headers (th elements) | –
[&lt;th&gt;][th]                         | creates a table header cell               | abbr, axis, colspan, rowspan, width, scope
[&lt;td&gt;][td]                         | creates a table cell in a "tr"" row       | abbr, axis, colspan, rowspan, width
[&lt;ol&gt;][ol]                         | creates a numbered ordered list           | start, reversed, type
[&lt;ul&gt;][ul]                         | creates is a bulleted unordered list      | type
[&lt;iframe&gt;][iframe]                 | An iframe can be used to embed web pages. | src, srcdoc, width, height, sandbox

### Complete list of available HTML tags
[`a`][a], [`abbr`][abbr], [`b`][b], [`bdo`][bdo], [`blockquote`][blockquote], [`br`][br], [`caption`][caption], [`cite`][cite], [`code`][code], [`col`][col], [`colgroup`][colgroup], [`dd`][dd], [`del`][del], [`dfn`][dfn], [`dl`][dl], [`dt`][dt], [`em`][em], [`figcaption`][figcaption], [`figure`][figure], [`h1`][h1], [`h2`][h2], [`h3`][h3], [`h4`][h4], [`h5`][h5], [`h6`][h6], [`hgroup`][hgroup], [`i`][i], [`iframe`][iframe], [`img`][img], [`ins`][ins], [`kbd`][kbd], [`li`][li], [`mark`][mark], [`ol`][ol], [`p`][p], [`pre`][pre], [`q`][q], [`rp`][rp], [`rt`][rt], [`ruby`][ruby], [`s`][s], [`samp`][samp], [`small`][small], [`strike`][strike], [`strong`][strong], [`sub`][sub], [`sup`][sup], [`table`][table], [`tbody`][tbody], [`td`][td], [`tfoot`][tfoot], [`th`][th], [`thead`][thead], [`time`][time], [`tr`][tr], [`u`][u], [`ul`][ul], [`var`][var], [`wbr`][wbr]

[a]:          https://developer.mozilla.org/en/HTML/Element/a
[abbr]:       https://developer.mozilla.org/en/HTML/Element/abbr
[b]:          https://developer.mozilla.org/en/HTML/Element/b
[bdo]:        https://developer.mozilla.org/en/HTML/Element/bdo
[blockquote]: https://developer.mozilla.org/en/HTML/Element/blockquote
[br]:         https://developer.mozilla.org/en/HTML/Element/br
[caption]:    https://developer.mozilla.org/en/HTML/Element/caption
[cite]:       https://developer.mozilla.org/en/HTML/Element/cite
[code]:       https://developer.mozilla.org/en/HTML/Element/code
[col]:        https://developer.mozilla.org/en/HTML/Element/col
[colgroup]:   https://developer.mozilla.org/en/HTML/Element/colgroup
[dd]:         https://developer.mozilla.org/en/HTML/Element/dd
[del]:        https://developer.mozilla.org/en/HTML/Element/del
[dfn]:        https://developer.mozilla.org/en/HTML/Element/dfn
[dl]:         https://developer.mozilla.org/en/HTML/Element/dl
[dt]:         https://developer.mozilla.org/en/HTML/Element/dt
[em]:         https://developer.mozilla.org/en/HTML/Element/em
[figcaption]: https://developer.mozilla.org/en/HTML/Element/figcaption
[figure]:     https://developer.mozilla.org/en/HTML/Element/figure
[h1]:         https://developer.mozilla.org/en/HTML/Element/h1
[h2]:         https://developer.mozilla.org/en/HTML/Element/h2
[h3]:         https://developer.mozilla.org/en/HTML/Element/h3
[h4]:         https://developer.mozilla.org/en/HTML/Element/h4
[h5]:         https://developer.mozilla.org/en/HTML/Element/h5
[h6]:         https://developer.mozilla.org/en/HTML/Element/h6
[hgroup]:     https://developer.mozilla.org/en/HTML/Element/hgroup
[i]:          https://developer.mozilla.org/en/HTML/Element/i
[iframe]:     https://developer.mozilla.org/en/HTML/Element/iframe
[img]:        https://developer.mozilla.org/en/HTML/Element/img
[ins]:        https://developer.mozilla.org/en/HTML/Element/ins
[kbd]:        https://developer.mozilla.org/en/HTML/Element/kbd
[li]:         https://developer.mozilla.org/en/HTML/Element/li
[mark]:       https://developer.mozilla.org/en/HTML/Element/mark
[ol]:         https://developer.mozilla.org/en/HTML/Element/ol
[p]:          https://developer.mozilla.org/en/HTML/Element/p
[pre]:        https://developer.mozilla.org/en/HTML/Element/pre
[q]:          https://developer.mozilla.org/en/HTML/Element/q
[rp]:         https://developer.mozilla.org/en/HTML/Element/rp
[rt]:         https://developer.mozilla.org/en/HTML/Element/rt
[ruby]:       https://developer.mozilla.org/en/HTML/Element/ruby
[s]:          https://developer.mozilla.org/en/HTML/Element/s
[samp]:       https://developer.mozilla.org/en/HTML/Element/samp
[small]:      https://developer.mozilla.org/en/HTML/Element/small
[strike]:     https://developer.mozilla.org/en/HTML/Element/strike
[strong]:     https://developer.mozilla.org/en/HTML/Element/strong
[sub]:        https://developer.mozilla.org/en/HTML/Element/sub
[sup]:        https://developer.mozilla.org/en/HTML/Element/sup
[table]:      https://developer.mozilla.org/en/HTML/Element/table
[tbody]:      https://developer.mozilla.org/en/HTML/Element/tbody
[td]:         https://developer.mozilla.org/en/HTML/Element/td
[tfoot]:      https://developer.mozilla.org/en/HTML/Element/tfoot
[th]:         https://developer.mozilla.org/en/HTML/Element/th
[thead]:      https://developer.mozilla.org/en/HTML/Element/thead
[time]:       https://developer.mozilla.org/en/HTML/Element/time
[tr]:         https://developer.mozilla.org/en/HTML/Element/tr
[u]:          https://developer.mozilla.org/en/HTML/Element/u
[ul]:         https://developer.mozilla.org/en/HTML/Element/ul
[var]:        https://developer.mozilla.org/en/HTML/Element/var
[wbr]:        https://developer.mozilla.org/en/HTML/Element/wbr

## <span id="linking">Linking to Notes</span>

Link directly to [any note][]: to find the URL (or permalink) of a note, open the note and select the link icon <span class="icon permalink" style="padding-left:16px;position:relative;top: -2px;">&#65279;</span>. Your browser's address bar will be updated to display the full URL of the annotation. The good stuff comes after the # symbol &mdash; in our [example][] the URL of the embedded document ends with <code>#document/p173/a8646</code>, so we know that the annotation is on page 173. The annotation itself is identifed by a random string (in this case "a8646").

You also can embed a note directly. See our [publishing and embedding](<a href="publishing">) documentation for details.

## <span id="printing">Printing Notes</span>

![Print Notes][]

It's easy to print out all the notes on a particular document or collection of documents. If you're in the workspace, select the documents, open the "Publish" menu, and click "Print Notes." While viewing a document, you'll find the link to "Print Notes" in the sidebar.

## <span id="deleting">Deleting Notes</span>

To remove a note from your document, open the note by clicking on it. Next, click the pencil icon at the top to enter edit mode. Then click the Delete button to remove the note. <strong>Important:</strong> Deleting a note cannot be undone, so proceed with caution.

# <span id="sections">Adding Sections for Navigation</span>

To help differentiate portions of a long document, you can add navigation links to the sidebar by defining sections. Inside of the document viewer, click on "Edit Sections" to open the Section Editor dialog. Add a title, starting page, and ending page for each section. Use the plus and minus icons to add and remove rows. When you're done, don't forget to save.

# <span id="questions">Questions?</span>

Still have questions about annotating documents? Don't hesitate to [contact us][].

[Annotations]: /images/help/document_annotations.jpg
[Notes Link]: /images/help/notes_link.jpg
[Print Notes]: /images/help/print_notes.png
[any note]: http://www.washingtonpost.com/wp-srv/business/documents/fcic-final-report.html#document/p173/a8646
[example]: http://www.washingtonpost.com/wp-srv/business/documents/fcic-final-report.html#document/p173/a8646
[contact us]: javascript:dc.ui.Dialog.contact()
