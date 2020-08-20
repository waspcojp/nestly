module NoticeLevelHelper
  DEFAULT = 0
  ALL_MEMBERS = 1
  INCLUDE_INVITED = 2
  PRIVATE_MEMBER_ONLY = 5
  PRIVATE = 9
  
  TYPES = [
           [ I18n.t("subscriber only"), DEFAULT ],
           [ I18n.t("all members"), ALL_MEMBERS ],
           [ I18n.t("include invited"), INCLUDE_INVITED ],
           [ I18n.t("private"), PRIVATE ]
          ]
end
