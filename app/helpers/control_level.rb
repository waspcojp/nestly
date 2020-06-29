module ControlLevel
  OPEN_GLOBAL = 0
  OPEN = 1
  MEMBERS_ONLY = 2
  BOARDS_ONLY = 3
  PRIVATE = 9
  
  TYPES = [
           [ I18n.t("open global"), OPEN_GLOBAL ],
           [ I18n.t("open"), OPEN ],
           [ I18n.t("members only"), MEMBERS_ONLY ],
           [ I18n.t("boards only"), BOARDS_ONLY ],
           [ I18n.t("private"), PRIVATE ]
          ]
end
