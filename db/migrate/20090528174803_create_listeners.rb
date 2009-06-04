class CreateListeners < ActiveRecord::Migration
  def self.up
    create_table :listeners do |t|
      t.string :status
      t.string :key
      t.string :subscriber_url
      t.string :action_url
      t.string :user
      t.string :password

      t.timestamps
    end
  end

  def self.down
    drop_table :listeners
  end
end
