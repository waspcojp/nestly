module ControlLevel
  OPEN_GLOBAL = 0
  OPEN = 1
  TRUSTED_GUEST_ONLY = 2
  MEMBERS_ONLY = 3
  BOARDS_ONLY = 4
  PRIVATE_MEMBER_ONLY = 5
  PRIVATE = 9
  
  TYPES = [
           [ I18n.t("open global"), OPEN_GLOBAL ],
           [ I18n.t("open"), OPEN ],
           # [ I18n.t("trusted guest only"), TRUSTED_GUEST_ONLY ],
           [ I18n.t("members only"), MEMBERS_ONLY ],
           [ I18n.t("boards only"), BOARDS_ONLY ],
           [ I18n.t("spaces.member_only"), PRIVATE_MEMBER_ONLY ],
           [ I18n.t("private"), PRIVATE ]
          ]
end
