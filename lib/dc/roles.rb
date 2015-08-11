module DC
  module Roles

    DISABLED      = 0
    ADMINISTRATOR = 1
    CONTRIBUTOR   = 2
    REVIEWER      = 3
    FREELANCER    = 4

    ROLE_MAP = {
      :disabled      => DISABLED,
      :administrator => ADMINISTRATOR,
      :admin         => ADMINISTRATOR,
      :contributor   => CONTRIBUTOR,
      :reviewer      => REVIEWER,
      :freelancer    => FREELANCER
    }
    ROLE_NAMES = ROLE_MAP.invert
    ROLES      = ROLE_NAMES.keys
    REAL_ROLES = [ADMINISTRATOR, CONTRIBUTOR, FREELANCER, DISABLED]
    ROLE_TITLES = Hash[ ROLE_MAP.map{ |name,id| [id, name.to_s.titleize] } ]
  end
end
