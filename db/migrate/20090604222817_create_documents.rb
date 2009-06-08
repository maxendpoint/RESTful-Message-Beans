class CreateDocuments < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.integer :listener_id
      t.string :key
      t.string :name
      t.string :comment
      t.string :content_type
      # If using MySQL, blobs default to 64k, so we have to give
      # an explicit size to extend them
      t.binary :data, :limit => 1.megabyte
      t.string :time_stamp

      t.timestamps
    end
  end

  def self.down
    drop_table :documents
  end
end
