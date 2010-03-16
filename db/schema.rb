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

ActiveRecord::Schema.define(:version => 20091019112815) do

  create_table "ch2_board_errors", :force => true do |t|
    t.string   "message"
    t.string   "trace"
    t.datetime "created_at"
    t.integer  "board_id"
  end

  add_index "ch2_board_errors", ["board_id"], :name => "index_ch2_board_errors_on_board_id"

  create_table "ch2_board_histories", :force => true do |t|
    t.string   "type"
    t.integer  "count"
    t.datetime "created_at"
    t.integer  "board_id"
  end

  add_index "ch2_board_histories", ["board_id"], :name => "index_ch2_board_histories_on_board_id"
  add_index "ch2_board_histories", ["created_at"], :name => "index_ch2_board_histories_on_created_at"

  create_table "ch2_boards", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.integer  "count"
    t.integer  "dat_size"
    t.integer  "position"
    t.string   "flags"
    t.datetime "created_at"
    t.datetime "written_at"
    t.integer  "site_id"
  end

  add_index "ch2_boards", ["site_id", "code"], :name => "index_ch2_boards_on_site_id_and_code"
  add_index "ch2_boards", ["site_id"], :name => "index_ch2_boards_on_site_id"

  create_table "ch2_habtm_boards_images", :id => false, :force => true do |t|
    t.integer "image_id"
    t.integer "board_id"
  end

  add_index "ch2_habtm_boards_images", ["board_id"], :name => "index_ch2_habtm_boards_images_on_board_id"
  add_index "ch2_habtm_boards_images", ["image_id"], :name => "index_ch2_habtm_boards_images_on_image_id"

  create_table "ch2_habtm_boards_keywords", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "board_id"
  end

  add_index "ch2_habtm_boards_keywords", ["board_id"], :name => "index_ch2_habtm_boards_keywords_on_board_id"
  add_index "ch2_habtm_boards_keywords", ["keyword_id"], :name => "index_ch2_habtm_boards_keywords_on_keyword_id"

  create_table "ch2_habtm_images_keywords", :id => false, :force => true do |t|
    t.integer "image_id"
    t.integer "keyword_id"
  end

  add_index "ch2_habtm_images_keywords", ["image_id"], :name => "index_ch2_habtm_images_keywords_on_image_id"
  add_index "ch2_habtm_images_keywords", ["keyword_id"], :name => "index_ch2_habtm_images_keywords_on_keyword_id"

  create_table "ch2_habtm_sites_negative_keywords", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "site_id"
  end

  add_index "ch2_habtm_sites_negative_keywords", ["keyword_id"], :name => "index_ch2_habtm_sites_negative_keywords_on_keyword_id"
  add_index "ch2_habtm_sites_negative_keywords", ["site_id"], :name => "index_ch2_habtm_sites_negative_keywords_on_site_id"

  create_table "ch2_habtm_sites_positive_keywords", :id => false, :force => true do |t|
    t.integer "keyword_id"
    t.integer "site_id"
  end

  add_index "ch2_habtm_sites_positive_keywords", ["keyword_id"], :name => "index_ch2_habtm_sites_positive_keywords_on_keyword_id"
  add_index "ch2_habtm_sites_positive_keywords", ["site_id"], :name => "index_ch2_habtm_sites_positive_keywords_on_site_id"

  create_table "ch2_image_summaries", :force => true do |t|
    t.integer  "board_count"
    t.datetime "created_at"
    t.integer  "image_id"
    t.string   "state",       :limit => 50
  end

  add_index "ch2_image_summaries", ["created_at"], :name => "index_ch2_image_summaries_created_at"
  add_index "ch2_image_summaries", ["image_id"], :name => "index_ch2_image_summaries_image_id"

  create_table "ch2_images", :force => true do |t|
    t.string   "url"
    t.string   "type"
    t.string   "flags"
    t.datetime "created_at"
    t.string   "digest",     :limit => 256
    t.integer  "score",                     :default => 0
    t.integer  "count",                     :default => 0
  end

  add_index "ch2_images", ["type"], :name => "index_ch2_images_on_type"
  add_index "ch2_images", ["url"], :name => "index_ch2_images_on_url"

  create_table "ch2_keywords", :force => true do |t|
    t.string "name"
    t.text   "keyword"
    t.string "source"
    t.string "flags"
  end

  create_table "ch2_operation_histories", :force => true do |t|
    t.string   "type"
    t.string   "arg"
    t.string   "remote_ip"
    t.string   "flags"
    t.datetime "created_at"
  end

  create_table "ch2_sites", :force => true do |t|
    t.string   "name"
    t.string   "code"
    t.string   "host"
    t.string   "flags"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "login_logs", :force => true do |t|
    t.string   "user"
    t.boolean  "result"
    t.string   "ip_address"
    t.string   "info"
    t.datetime "created_at"
  end

  create_table "materials", :force => true do |t|
    t.string   "label"
    t.string   "filename"
    t.string   "mime_type",  :limit => 50
    t.integer  "size"
    t.datetime "created_at"
    t.string   "file"
  end

  add_index "materials", ["file"], :name => "unique_index_materials_file", :unique => true
  add_index "materials", ["mime_type"], :name => "index_materials_mime_type"

  create_table "notices", :force => true do |t|
    t.string   "body"
    t.datetime "started_at"
    t.datetime "stopped_at"
  end

  create_table "open_id_authentication_associations", :force => true do |t|
    t.integer "issued"
    t.integer "lifetime"
    t.string  "handle"
    t.string  "assoc_type"
    t.binary  "server_url"
    t.binary  "secret"
  end

  create_table "open_id_authentication_nonces", :force => true do |t|
    t.integer "timestamp",  :null => false
    t.string  "server_url"
    t.string  "salt",       :null => false
  end

  create_table "schema_columns", :force => true do |t|
    t.string  "name"
    t.string  "type"
    t.string  "label"
    t.boolean "listable"
    t.boolean "showable"
    t.boolean "searchable"
    t.integer "position"
    t.integer "schema_table_id"
  end

  create_table "schema_tables", :force => true do |t|
    t.string   "name"
    t.boolean  "enabled"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "user"
    t.string   "pass"
    t.string   "flags"
    t.string   "name"
    t.integer  "exp"
    t.datetime "logined_at"
    t.datetime "created_at"
  end

end
