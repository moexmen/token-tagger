# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_02_21_104929) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "students", force: :cascade do |t|
    t.string "school_code", null: false
    t.string "school_name"
    t.string "school_cluster"
    t.string "name", null: false
    t.string "class_name"
    t.string "level"
    t.string "nric", null: false
    t.string "contact", null: false
    t.string "token_id"
    t.string "status", default: "pending"
    t.string "batch"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "serial_no", null: false
    t.index ["token_id"], name: "index_students_on_token_id", unique: true
  end

end
