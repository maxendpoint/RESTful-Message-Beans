class CreateListeners < ActiveRecord::Migration
  def self.up
    create_table :listeners do |t|
      t.string :key
      
      #subscriber attributes
      t.string :subscriber_url
      t.string :subscriber_host
      t.integer :subscriber_port
      t.string :subscriber_user
      t.string :subscriber_password
      
      #submitter attributes
      t.string :submitter_login_url
      t.string :submitter_delivery_url
      t.string :submitter_user
      t.string :submitter_password
      
      t.timestamps
    end
  end

  def self.down
    drop_table :listeners
  end
end
