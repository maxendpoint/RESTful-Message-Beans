# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090612010321) do

  create_table "documents", :force => true do |t|
    t.integer  "listener_id"
    t.string   "key"
    t.string   "destination"
    t.string   "message_ID"
    t.string   "content_type"
    t.string   "priority"
    t.string   "content_length"
    t.string   "time_stamp"
    t.string   "expiry"
    t.binary   "data",           :limit => 16777215
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listeners", :force => true do |t|
    t.string   "status"
    t.string   "key"
    t.string   "subscriber_url"
    t.string   "subscriber_host"
    t.integer  "subscriber_port"
    t.string   "subscriber_user"
    t.string   "subscriber_password"
    t.string   "receiver_login_url"
    t.string   "receiver_delivery_url"
    t.string   "receiver_user"
    t.string   "receiver_password"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "pictures", :force => true do |t|
    t.string "comment"
    t.string "name"
    t.string "content_type"
    t.binary "data",         :limit => 16777215
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "hashed_password"
    t.string   "salt"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
