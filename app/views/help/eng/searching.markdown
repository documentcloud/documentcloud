# Searching for Documents

By default, a search looks for all of the words you enter within the title and full text of the document itself. For example: [John Yoo detainee][]. You can, however, ask DocumentCloud to search the contents of specific fields.

## Advanced Queries
Enclose terms in quotes to search for a specific, multi-word phrase. `"Robert Smith"`

Use Boolean search operators such as `and` and `or` with parentheses for grouping, and use `!` to exclude terms from your results.

For example: `(geithner and bernanke) !madoff`

You may also use `*` for "wildcard" searches, so a search of `J* Brown` will match both `"Jerry Brown"` and `"John Brown"`.

## <span id="builtin">Searching by Built-in Metadata Field</span>

Term                        | Description
----------------------------|---------------------
title                       | Will search for documents by title as provided by the person who uploaded it. For example: [title: deepwater][].
source                      | When you upload a document, you have the opportunity to identify the source. This provides a way to search that field. For example: [source: supreme][] will identify documents attributed to "U.S. Supreme Court" as well as "New York State Supreme Court."
description                 | Search for a word or phrase within a document's description. For example: [description: manifesto][].
account                     | Specify an account id to see documents uploaded by a single user. Click on the toggle triangle in the top left corner of the "Documents" tab to reveal a list of all the accounts in your organization. For example: [account: 7-scott-klein][].
group                       | If you know the short name of an organization, you can search for documents uploaded by anyone in that newsroom. For example: [group: chicago-tribune][]. You can also filter by clicking on the organization's name in the document list.
project                     | Restrict your search to just the documents in one of your projects by entering the title. This is the same as clicking on the project in the "Documents" tab.
projectid                   | Restrict your search to a particular project by a project's canonical identifier. Useful for filtering public API calls. You can view this ID by opening the project's edit dialog. For example: [projectid: 6-the-financial-crisis][]
access                      | Search for only documents that have a particular access level (one of "public," "private," or "organization"). For example, to view all of your private documents: [access: private][]
filter                      | Filter documents by interesting criteria (one of "published," "unpublished," "annotated," or "popular"). For example, to view all published documents: [filter: published][]

## <span id="viewing_entities">Viewing Entities</span>

![OpenCalais Logo][]

Whenever you upload a document to DocumentCloud we send the contents to [OpenCalais][], a service that discovers the entities (people, places, organizations, terms, etc.) present in plain text. OpenCalais can tell us that "Barack Obama" is the same person as "President Obama," "Senator Obama," "Mr. President" ... and even "he" or "his" in clauses such as "his policy proposals."

To view entities, select a document and choose **View Entities** from the **Analyze** menu ... or right-click on a document and choose **View Entities** from the context menu. The entities will be displayed in a chart that shows how often each entity occurs across each page. Using this chart, you can see which companies and individuals tend to be mentioned together frequently, or which parts of a long document concern a certain topic. Hover over any mention (the small gray boxes) to see the surrounding context, and click on it to jump directly to that mention within the document itself.

<img alt="" src="/images/help/entities.png" class="full_line" />

## <span id="metadata">Editing and Searching your own Custom Data</span>

DocumentCloud allows you to define and search your own set of custom data (key/value pairs) associated with specific documents. To get started with document data, you can use [the API][] to add data to your documents in bulk &mdash; useful if you already have an existing database of information about your documents.

To edit data for individual documents in the workspace, select the documents you wish to update, and choose **Edit Document Data** from the **Edit** menu ... or right-click on a document, and choose **Edit Document Data** from the context menu.

<img alt="" src="/images/help/edit_document_data.png" class="full_line" />

A dialog will appear which you can use to view the existing key/value pairs, add new pairs, and remove old ones.

To filter documents by data that you've added, either click on the tag (shown in the picture above), or search for the key/value pair as you would for any other field by typing `citizen: Pakistan` into the search box.

You can enter the same key multiple times with different values for an "or" search. To search for all citizens of Pakistan *or* Yemen: `citizen: Pakistan citizen: Yemen`

If you'd like to filter all documents with a `citizen` key, but you don't care about the value, you can use: `citizen: *`

To find all the documents that *don't* have a `citizen` key yet, use: `citizen: !`

Still have questions about how to search? Don't hesitate to [contact us][].

To see the details of how to use our search API, view the [API documentation][].


[OpenCalais]: http://www.opencalais.com/
[OpenCalais Logo]: /images/help/opencalais.jpg
[contact us]: javascript:dc.ui.Dialog.contact()
