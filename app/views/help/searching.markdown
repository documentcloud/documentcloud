# Searching for Documents

This guide lists the different types of searches you can perform with DocumentCloud. You can click any of the linked examples to run the search and try it out.

By default, a search looks for all of the words you enter within the full text of the document itself. For example: [John Yoo detainee][]. You can, however, ask DocumentCloud to search the contents of specific other fields.

When entering a fielded search, if the phrase you're searching for contains spaces, use quotation marks to surround the phrase. If there are no spaces, quotes aren't necessary.
   
Term                        | Description 
----------------------------|---------------------
account                     | Specify an email address to see documents uploaded by a single user. For example: [account: scott.klein@propublica.org][].
group                       | If you know the short name of an organization, you can search for documents uploaded by anyone in that newsroom. For example: [group: chicago-tribune][].
project                     | Restrict your search to just the documents in one of your projects, by entering the title. This is the same as clicking on the project in the "Projects" tab.
title                       |	Will search for documents by title, as provided by the person who uploaded it. For example: [title: deepwater][]
source                      | When you upload a document, you have the opportunity to identify the source. This provides a way to search that field. For example: [source: supreme][] will identify documents attributed to "U.S. Supreme Court" as well as "New York State Supreme Court."
 
# Searching with Entities
 
For each document we store a list of entities identified by [OpenCalais][]. These are the same entities that appear in the "Entities" tab on the left. After searching for an entity, you can click on "show pages" to display links to the specific pages in each document that mention the person, place or thing you're searching for.

Term                        | Description 
----------------------------|-------------------------
person                      | The name of a human being. If you're looking for documents that reference a person with the last name of "Lee", but keep getting swamped with unrelated words, try narrowing your search to [person: Lee][].
organization                | Organizations include businesses, government agencies, and other types of institutions. For example: [organization: "Department of Defense"][].
term                        | Searches for terms might include [term: "nuclear energy"][] or [term: "gross domestic product"][] The results will be comparable to searching for the terms directly.
place                       | Addresses, names of buildings and landmarks, regions, or geographical landmarks. For example: [place: "World Trade Center"][] or [place: "Gulf of Mexico"][].
city                        | For example: [city: "New Orleans"][]
state                       | (Includes provinces, in countries that have provinces instead of states.) For example: [state: Arizona][]
country                     | For example: [country: Iran][]

Still have questions about how to search? Don't hesitate to [contact us][].

[contact us]: javascript:dc.app.workspace.help.openContactDialog()
[John Yoo detainee]: #search/John%20Yoo%20detainee
[account: scott.klein@propublica.org]: #search/account%3A%20scott.klein%40propublica.org
[group: chicago-tribune]: #search/group%3A%20chicago-tribune
[title: deepwater]: #search/title%3A%20deepwater
[source: supreme]: #search/source%3A%20supreme
[OpenCalais]: http://www.opencalais.com/
[person: Lee]: #search/person%3A%20Lee
[organization: "Department of Defense"]: #search/organization%3A%20%22Department%20of%20Defense%22
[term: "nuclear energy"]: #search/term%3A%20%22nuclear%20energy%22
[term: "gross domestic product"]: #search/term%3A%20%22gross%20domestic%20product%22
[place: "World Trade Center"]: #search/place%3A%20%22World%20Trade%20Center%22
[place: "Gulf of Mexico"]: #search/place%3A%20%22Gulf%20of%20Mexico%22
[city: "New Orleans"]: #search/city%3A%20%22New%20Orleans%22
[state: Arizona]: #search/state%3A%20Arizona
[country: Iran]: #search/country%3A%20Iran
