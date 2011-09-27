# Searching for Documents

By default, a search looks for all of the words you enter within the title and full text of the document itself. For example: [John Yoo detainee][]. You can, however, ask DocumentCloud to search the contents of specific fields.

## Advanced Queries
Enclose terms in quotes to search for a specific, multi-word phrase. `"Robert Smith"` 

Use Boolean search operators, like `and` and `or` in conjunction with parentheses for grouping, and `!` to exclude terms that shouldn't be present in your results. 

For example: `(geithner and bernanke) !madoff`

You may also use `*` for "wildcard" searches, so a search of `J* Brown` will match both `"Jerry Brown"` and `"John Brown"`.

## <span id="builtin">Searching by Built-in Metadata Field</span>
   
Term                        | Description 
----------------------------|---------------------
title                       |	Will search for documents by title, as provided by the person who uploaded it. For example: [title: deepwater][].
source                      | When you upload a document, you have the opportunity to identify the source. This provides a way to search that field. For example: [source: supreme][] will identify documents attributed to "U.S. Supreme Court" as well as "New York State Supreme Court."
description                 | Search for a word or phrase within a document's description. For example: [description: manifesto][].
account                     | Specify an account id to see documents uploaded by a single user. Click on the toggle triangle in the top left corner of the "Documents" tab, to reveal a list of all the accounts in your organization. For example: [account: 7-scott-klein][].
group                       | If you know the short name of an organization, you can search for documents uploaded by anyone in that newsroom. For example: [group: chicago-tribune][]. You can also filter by clicking on the organization's name in the document list.
project                     | Restrict your search to just the documents in one of your projects, by entering the title. This is the same as clicking on the project in the "Documents" tab.
projectid                   | Restrict your search to a particular project, by a project's canonical identifier. Useful for filtering public API calls. You can view this ID by opening the project's edit dialog. For example: [projectid: 6-the-financial-crisis][]
access                      | Search for only documents that have a particular access level (one of "public", "private", or "organization"). For example, to view all of your private documents: [access: private][]
filter                      | Filter documents by interesting criteria (one of "published", "unpublished", "annotated", or "popular"). For example, to view all published documents: [filter: published][]
 
## <span id="entities">Searching with Entities</span>
 
For each document we store a list of entities identified by [OpenCalais][]. These are the same entities that appear in the "Entities" tab on the left. After searching for an entity, you can click on "show pages" to display links to the specific pages in each document that mention the person, place or thing you're searching for.

Term                        | Description 
----------------------------|-------------------------
person                      | The name of a human being. If you're looking for documents that reference a person with the last name of "Lee", but keep getting swamped with unrelated words, try narrowing your search to [person: Lee][].
organization                | Organizations include businesses, government agencies, and other types of institutions. For example: [organization: "Department of Defense"][].
place                       | Addresses, names of buildings and landmarks, regions, or geographical landmarks. For example: [place: "World Trade Center"][] or [place: "Gulf of Mexico"][].
term                        | Searches for terms might include [term: "nuclear energy"][] or [term: "gross domestic product"][]. The results will be comparable to searching for the terms directly.
email                       | Complete email addresses. Documents that mention the email address of the GAO FraudNet can be found with this search: [email: fraudnet@gao.gov][].
phone                       | Telephone or Fax numbers. For example: [phone: "(251) 441-6216"][].
city                        | For example: [city: "New Orleans"][].
state                       | (Includes provinces, in countries that have provinces instead of states.) For example: [state: Arizona][].
country                     | For example: [country: Iran][].

## <span id="metadata">Editing and Searching your own Custom Data</span>

DocumentCloud allows you to define and search your own set of custom data (key/value pairs) associated with specific documents. To get started with document data, you can use [the API][] to add data to your documents in bulk &mdash; useful if you already have an existing database of information about your documents.

To edit data for individual documents in the workspace, select the documents you wish to update, and choose **Edit Document Data** from the **Edit** menu ... or right-click a document, and choose **Edit Document Data** from the context menu.

<img alt="" src="/images/help/edit_document_data.png" class="full_line" />

A dialog will appear which you can use to view the existing key/value pairs, add new pairs, and remove old ones.

To filter documents by data that you've added, either click on the tag (shown in the picture above), or search for the key/value pair as you would for any other field, by typing `citizen: Pakistan` into the search box.

If you'd like to filter all documents with a `citizen` key, but you don't care about the value, you can use: `citizen: *`

Still have questions about how to search? Don't hesitate to [contact us][].

To see the details of how to use our search API, view the [API documentation][].


[OpenCalais]: http://www.opencalais.com/
[contact us]: javascript:dc.ui.Dialog.contact()
