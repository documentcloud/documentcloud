# Keep this file in sync with model/access.js

module DC

  # Mapping of access levels to integers, for efficient storage/querying.
  module Access

    DELETED       = 0   # The document was deleted, and will be removed soon.
    PRIVATE       = 1   # The document is only visible to its owner.
    ORGANIZATION  = 2   # Visible to both the owner and her organization.
    EXCLUSIVE     = 3   # Published, but exclusive to the owner's organization.
    PUBLIC        = 4   # Free and public to all.
    PENDING       = 5   # The document is being processed (acts as disabled).
    INVISIBLE     = 6   # The document has been taken down (perhaps temporary).
    ERROR         = 7   # The document is broken, or failed to import.
    PREMODERATED  = 8   # The document is open to premoderated reader input
    POSTMODERATED = 9   # The document is open to postmoderated reader input

    ACCESS_MAP = {
      :deleted      => DELETED,
      :private      => PRIVATE,
      :organization => ORGANIZATION,
      :exclusive    => EXCLUSIVE,
      :public       => PUBLIC,
      :pending      => PENDING,
      :invisible    => INVISIBLE,
      :error        => ERROR,
      :premoderated => PREMODERATED,
      :postmoderated => POSTMODERATED
    }

    ACCESS_NAMES = ACCESS_MAP.invert

    SHARED_ACCESS    = [ORGANIZATION, EXCLUSIVE, PUBLIC, PENDING, ERROR, PREMODERATED, POSTMODERATED]
    PUBLIC_LEVELS    = [PUBLIC, PREMODERATED, POSTMODERATED]
    ACCESS_SUCCEEDED = ACCESS_NAMES.keys - [ DELETED, INVISIBLE, ERROR, PENDING ]

  end

end
