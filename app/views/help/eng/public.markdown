# DocumentCloud's Public Catalog

DocumentCloud is a robust document research, organization and publishing tool used by thousands of people worldwide to find information in primary source documents and share those documents with readers.

We offer a public repository of documents that anyone can search. Some tips on how to:

## Search public documents and browse the notes.

Try a search for [gulf oil spill][] to find all public documents with "gulf," "oil" and "spill" in the text or title. Your results will include documents relating to the British Petroleum oil spill in the Gulf of Mexico. For each document, you can see the name of the user who uploaded the document and the organization they work in.

If a user has annotated a document, you'll also see a yellow "note" indicator on the document's thumbnail. Below the thumbnail, there's a small link you can use to show the annotations on that document.

Double click any document to read the whole document in our viewer.

## Try out our analytic tools.

DocumentCloud gives you access to a great set of analytic tools. When a user uploads a document, we run it through OCR, which extracts letters and words from the document's image. But that's not all.

Search for [source: "House Committee on the Judiciary"][].

Your results will include a handful of documents related to a DOJ report on Bush administration interrogation policies. Select all of the interrogation documents and select "View Timeline" from the "Analyze" menu.

<img src="/images/help/timeline.jpg" class="full_line" alt="Timeline example." />

Every date reference in this collection of documents is plotted on a timeline. Hover over any dot to see the exact date in context. Click on the dot to open a document viewer to the location of that date in the text.

Close the timeline and select the "Entities" tab at the top left of the screen to view you a series of expandable lists of **people**, **organizations**, **places**, and **terms** mentioned in the documents. You'll see "John Yoo" at the top of the list, with the counter `(8)` next to his name, because he's named in all eight of the documents. Select his name to refine your search, and then select the "show pages" to dispaly a thumbnail of each page where John Yoo is mentioned. Selecting a thumbnail or highlighted link will jump directly to his name on that particular page.

<img src="/images/help/show_pages.png" class="full_line" />

## Advanced Searches

Enclose terms in quotes to search for a specific multi-word phrase.  

Use "NOT" or "-" to exclude a term from your search. For example these searches: [geithner -madoff][] and [geithner NOT madoff][] will return documents that mention "Geithner" and do not also mention "Madoff."

By default, DocumentCloud will search both the title and full text of every document for all of the words in your search term. You can, however, ask DocumentCloud to search the contents of specific fields.


## Searching by Metadata Field

Term                        | Description
----------------------------|---------------------
title                       | Will search only the titles of documents. For example: [title: deepwater][].
source                      | Reporters have the opportunity to identify the source of each document they upload. For example: [source: supreme][] will identify documents attributed to "U.S. Supreme Court" plus various state supreme courts.
description                 | Search for a word or phrase within all document descriptions. For example: [description: manifesto][].
account                     | Specify an account id to see documents published by a specific user. Notice that clicking on any user's name in your search results will automatically filter your results to include only that user's documents.  For example: [account: 149-brad-heath][].
group                       | Search for all documents made public by a single newsroom. Notice that clicking on any organization name in your search results will automatically filter your results to include only that group's documents. For example: [group: chicago-tribune][].
projectid                   | Reporters can organize documents into as many projects as appropriate. To restrict a search to documents in one project, you need to know that project's canonical identifier or project id. DocumentCloud doesn't publish individual project id's, however.  For example: [projectid: 6-the-financial-crisis][]
filter                      | Filter documents by interesting criteria (one of "published", "unpublished", "annotated", or "popular"). For example, to view all published documents: [filter: published][]

## Searching with Entities

For each document, we store a list of entities identified by [OpenCalais][]. These are the same entities that appear in the "Entities" tab. After searching for an entity, you can click on "show pages" to display links to the specific pages in each document that mention the person, place or thing you're searching for.

Term                        | Description
----------------------------|-------------------------
person                      | The name of a human being. If you're looking for documents that reference a person with the last name of "Lee", but keep getting swamped with unrelated words, try narrowing your search to [person: Lee][].
organization                | Organizations include businesses, government agencies, and other types of institutions. For example: [organization: "Department of Defense"][].
place                       | Addresses, names of buildings and landmarks, regions, or geographical landmarks. For example: [place: "World Trade Center"][] or [place: "Gulf of Mexico"][].
term                        | Searches for terms might include [term: "nuclear energy"][] or [term: "gross domestic product"][]. The results will be comparable to searching for the terms directly.
email                       | Complete email addresses. Documents that mention the email address of the GAO FraudNet can be found with this search: [email: fraudnet@gao.gov][].
phone                       | Telephone or fax numbers. For example: [phone: "(251) 441-6216"][].
city                        | For example: [city: "New Orleans"][].
state                       | (Includes provinces in countries that have provinces instead of states.) For example: [state: Arizona][].
country                     | For example: [country: Iran][].

Questions? Don't hesitate to [contact us][]. And as you go, feel free to [request features and report bugs][].

[gulf oil spill]: /public/search/gulf%20oil%20spill
[source: "House Committee on the Judiciary"]: /public/search/source%3A%20%22House%20Committee%20on%20the%20Judiciary%22
[John Yoo detainee]: /public/search/John%20Yoo%20detainee
[geithner -madoff]: /public/search/geithner%20-madoff
[geithner NOT madoff]: /public/search/geithner%20NOT%20madoff
[account: 149-brad-heath]: /public/search/account%3A%20149-brad-heath
[group: chicago-tribune]: /public/search/group%3A%20chicago-tribune
[title: deepwater]: /public/search/title%3A%20deepwater
[source: supreme]: /public/search/source%3A%20supreme
[description: manifesto]: /public/search/description%3A%20manifesto
[projectid: 6-the-financial-crisis]: /public/search/projectid%3A%206-the-financial-crisis
[access: private]: /public/search/access%3A%20private
[filter: published]: /public/search/filter%3A%20published
[person: Lee]: /public/search/person%3A%20Lee
[organization: "Department of Defense"]: /public/search/organization%3A%20%22Department%20of%20Defense%22
[term: "nuclear energy"]: /public/search/term%3A%20%22nuclear%20energy%22
[term: "gross domestic product"]: /public/search/term%3A%20%22gross%20domestic%20product%22
[email: fraudnet@gao.gov]: /public/search/%20email%3A%20fraudnet%40gao.gov
[phone: "(251) 441-6216"]: /public/search/%20phone%3A%20%22(251)%20441-6216%22
[place: "World Trade Center"]: /public/search/place%3A%20%22World%20Trade%20Center%22
[place: "Gulf of Mexico"]: /public/search/place%3A%20%22Gulf%20of%20Mexico%22
[city: "New Orleans"]: /public/search/city%3A%20%22New%20Orleans%22
[state: Arizona]: /public/search/state%3A%20Arizona
[country: Iran]: /public/search/country%3A%20Iran
[OpenCalais]: http://new.opencalais.com/
[contact us]: /contact
[request features and report bugs]: http://documentcloud.uservoice.com
