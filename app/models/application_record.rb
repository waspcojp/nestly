class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def released?
    (( released_at ) && ( released_at < Time.now )) ? true : false
  end
end
