class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.integer :listener_id
      t.string :key
      t.string :destination
      t.string :message_ID
      t.string :content_type
      t.string :priority
      t.string :content_length
      t.string :time_stamp
      t.string :expiry
      t.string :data_file
      # If using MySQL, blobs default to 64k, so we have to give
      # an explicit size to extend them
      t.binary :data, :limit => 1.megabyte
    
      t.timestamps
      
    end
  end

  def self.down
    drop_table :documents
  end
end
