class History < ApplicationRecord
  belongs_to :target, polymorphic: true
  after_create :send_message

  def self.log(operation, obj)
    rec = History.new
    rec.target = obj
    rec.operation = operation
    if ( operation != :destroy )
      body = obj.attributes
      body.delete('id')
      body.delete('updated_at')
      body.delete('created_at')
      rec.body = body.to_json
    end
    rec.save
  end
  def send_message
    self.target.send_message_callback(self)
  end
end
