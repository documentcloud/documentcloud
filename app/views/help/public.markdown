# Welcome to DocumentCloud

DocumentCloud is a tool for organizing and working with large documents and document collections, a document viewer that makes it easier for reporters to share source material with readers and a publicly accessible repository of primary source documents that were used in reporters' investigations. If you're new to this, take a look at some [recent news stories that use DocumentCloud for primary source material][].

## Finding Your Way Around the Workspace

If you're looking at a list of documents (search results, featured document, a single news organization) you can click on a thumbnail image to select that document. It works the same way as icons on your desktop: you can use the shift or control (command) keys, or drag across to select multiple documents at once. With documents selected, you can use the toolbar to view entities, plot extracted dates on a timeline, or download the original documents in PDF form.

<img src="/images/help/drag_select.png" class="full_line" />

Double-click a document's icon to launch the document viewer, where you can read the document and browse its annotations.

## Try a search of public documents.

Search for [gulf oil spill][].

This will search all documents made public by any DocumentCloud user for documents with "gulf," "oil" and "spill" in the text or title. Your results should include a number of documents relating to the British Petroleum oil spill in the Gulf of Mexico.

## Browse the notes.

Some of the documents will have yellow notes attached. Click on the "Show Notes" link below the document's icon. The notes will be displayed, along with the relevant portion of the original page.

## Try our analytic tools.

DocumentCloud gives you access to a great set of analytic tools for working with large and small documents. When a document is uploaded, we run it through OCR, which extracts letters and words from the documents' image. But that's not all. 
 
Search for [source: "House Committee on the Judiciary"][].
 
Your results will include a handful of documents related to a DOJ report on Bush administration interrogation policies. Select all 8 of the interrogation documents and click the "Timeline" button:

<img src="/images/help/timeline.jpg" class="full_line" />

All of the dates named in these documents are plotted on a timeline. Hover over any dot to see the exact date, along with an excerpt of the text where the date is mentioned. Click on the dot to open up a document viewer, jumping directly to the location of the date in the text.
 
Close the timeline and click the "Entities" tab, at the top left of the screen. This will show you a series of expandable lists of the **people**, **organizations**, **places**, and **terms** mentioned in the documents. You'll see "John Yoo" at the top of the list, with the counter `(8)` next to his name, because he's named in all eight of the documents. Click his name to refine your search, and then click the "show pages" link that appears right next to it. Underneath each document, you'll now see each page that contains a mention of John Yoo, along with an excerpt. Click on any of the thumbnails, or on the highlighted link, to jump directly to his name on that particular page.

<img src="/images/help/show_pages.png" class="full_line" />

## Searching the Full Text of Documents

By default, a search looks for all of the words you enter within the title and full text of the document itself. For example: [John Yoo detainee][]. You can, however, ask DocumentCloud to search the contents of specific fields.

Enclose terms in quotes to search for a specific, multi-word phrase.  

Use "NOT" or "-" to exclude a term from your search. For example both: [geithner -madoff][] and [geithner NOT madoff][] will return documents that mention "Geithner" and do not also mention "Madoff." 

## Searching by Metadata Field
   
Term                        | Description 
----------------------------|---------------------
title                       |	Will search for documents by title, as provided by the person who uploaded it. For example: [title: deepwater][].
source                      | When you upload a document, you have the opportunity to identify the source. This provides a way to search that field. For example: [source: supreme][] will identify documents attributed to "U.S. Supreme Court" as well as "New York State Supreme Court."
description                 | Search for a word or phrase within a document's description. For example: [description: manifesto][].
account                     | Specify an account id to see documents uploaded by a single user. Click on the toggle triangle in the top left corner of the "Documents" tab, to reveal a list of all the accounts in your organization. For example: [account: 7-scott-klein][].
group                       | If you know the short name of an organization, you can search for documents uploaded by anyone in that newsroom. For example: [group: chicago-tribune][]. You can also filter by clicking on the organization's name in the document list.
project                     | Restrict your search to just the documents in one of your projects, by entering the title. This is the same as clicking on the project in the "Documents" tab.
projectid                   | Restrict your search to a particular project, by a project's canonical identifier. Useful for filtering public API calls. You can view this ID by opening the project's edit dialog. For example: [projectid: 6-the-financial-crisis][]
access                      | Search for only documents that have a particular access level (one of "public", "private", "organization", "published", or "unpublished"). For example, to view all of your private documents: [access: private][]
 
## Searching with Entities
 
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

To see the details of how to use our search API, visit the API documentation at [documentcloud.org/help/api][].

Questions? Don't hesitate to [contact us][]. And as you go, feel free to [request features and report bugs][].

<div class="help_footer">
  <a class="text_link" href="/contact">Contact Us</a> &nbsp;&nbsp;|&nbsp;&nbsp;
  <a class="text_link" href="/terms">Terms of Service</a> &nbsp;&nbsp;|&nbsp;&nbsp;
  <a class="text_link" href="/privacy">Privacy Policy</a>
</div>


[recent news stories that use DocumentCloud for primary source material]: /featured
[gulf oil spill]: #search/gulf%20oil%20spill
[source: "House Committee on the Judiciary"]: #search/source%3A%20%22House%20Committee%20on%20the%20Judiciary%22
[John Yoo detainee]: #search/John%20Yoo%20detainee
[geithner -madoff]: #search/geithner%20-madoff 
[geithner NOT madoff]: #search/geithner%20NOT%20madoff
[account: 7-scott-klein]: #search/account%3A%207-scott-klein
[group: chicago-tribune]: #search/group%3A%20chicago-tribune
[title: deepwater]: #search/title%3A%20deepwater
[source: supreme]: #search/source%3A%20supreme
[description: manifesto]: #search/description%3A%20manifesto
[projectid: 6-the-financial-crisis]: #search/projectid%3A%206-the-financial-crisis
[access: private]: #search/access%3A%20private
[person: Lee]: #search/person%3A%20Lee
[organization: "Department of Defense"]: #search/organization%3A%20%22Department%20of%20Defense%22
[term: "nuclear energy"]: #search/term%3A%20%22nuclear%20energy%22
[term: "gross domestic product"]: #search/term%3A%20%22gross%20domestic%20product%22
[email: fraudnet@gao.gov]: #search/%20email%3A%20fraudnet%40gao.gov
[phone: "(251) 441-6216"]: #search/%20phone%3A%20%22(251)%20441-6216%22
[place: "World Trade Center"]: #search/place%3A%20%22World%20Trade%20Center%22
[place: "Gulf of Mexico"]: #search/place%3A%20%22Gulf%20of%20Mexico%22
[city: "New Orleans"]: #search/city%3A%20%22New%20Orleans%22
[state: Arizona]: #search/state%3A%20Arizona
[country: Iran]: #search/country%3A%20Iran
[OpenCalais]: http://www.opencalais.com/
[documentcloud.org/help/api]: http://www.documentcloud.org/help/api
[contact us]: javascript:dc.ui.Dialog.contact()
[request features and report bugs]: http://documentcloud.uservoice.com
