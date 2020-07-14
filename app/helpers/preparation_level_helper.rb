module PreparationLevelHelper
  TRUSTED_GUEST_ONLY = 2
  MEMBERS_ONLY = 3
  BOARDS_ONLY = 4
  PRIVATE = 9
  
  TYPES = [
           # [ I18n.t("trusted guest only"), TRUSTED_GUEST_ONLY ],
           [ I18n.t("members only"), MEMBERS_ONLY ],
           [ I18n.t("boards only"), BOARDS_ONLY ],
           [ I18n.t("private"), PRIVATE ]
          ]
end
