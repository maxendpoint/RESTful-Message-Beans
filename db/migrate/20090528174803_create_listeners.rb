class CreateListeners < ActiveRecord::Migration
  def self.up
    create_table :listeners do |t|
      t.string :status
      t.string :key
      
      #subscriber attributes
      t.string :subscriber_url
      t.string :subscriber_host
      t.string :subscriber_port
      t.string :subscriber_user
      t.string :subscriber_password
      
      #receiver attributes
      t.string :receiver_login_url
      t.string :receiver_delivery_url
      t.string :receiver_user
      t.string :receiver_password
      
      t.timestamps
    end
  end

  def self.down
    drop_table :listeners
  end
end
