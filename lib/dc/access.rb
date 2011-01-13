# Keep this file in sync with model/access.js

module DC

  # Mapping of access levels to integers, for efficient storage/querying.
  module Access

    DELETED       = 0   # The document was deleted, and will be removed soon.
    PRIVATE       = 1   # The document is only visible to it's owner.
    ORGANIZATION  = 2   # Visible to both the owner and her organization.
    EXCLUSIVE     = 3   # Published, but exclusive to the owner's organization.
    PUBLIC        = 4   # Free and public to all.
    PENDING       = 5   # The document is being processed (acts as disabled).
    INVISIBLE     = 6   # The document has been taken down (perhaps temporary).
    ERROR         = 7   # The document is broken, or failed to import.

    ACCESS_MAP = {
      :deleted      => DELETED,
      :private      => PRIVATE,
      :organization => ORGANIZATION,
      :exclusive    => EXCLUSIVE,
      :public       => PUBLIC,
      :pending      => PENDING,
      :invisible    => INVISIBLE,
      :error        => ERROR
    }

    ACCESS_NAMES = ACCESS_MAP.invert

  end

end