module PreparationLevelHelper
  MEMBERS_ONLY = 2
  BOARDS_ONLY = 3
  PRIVATE = 9
  
  TYPES = [
           [ I18n.t("members only"), MEMBERS_ONLY ],
           [ I18n.t("boards only"), BOARDS_ONLY ],
           [ I18n.t("private"), PRIVATE ]
          ]
end
