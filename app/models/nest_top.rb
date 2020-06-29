class NestTop < ApplicationRecord
  has_one :nest, class_name: "Nest", foreign_key: :design
end
