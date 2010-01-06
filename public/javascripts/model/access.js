// Keep this file in sync with lib/dc/access.rb

dc.access = {

  DELETED       : 0,   // The document was deleted, and will be removed soon.
  PRIVATE       : 1,   // The document is only visible to it's owner.
  ORGANIZATION  : 2,   // Visible to both the owner and her organization.
  EXCLUSIVE     : 3,   // Published, but exclusive to the owner's organization.
  PUBLIC        : 4,   // Free and public to all.
  PENDING       : 5    // The document is being processed (acts as disabled).

};