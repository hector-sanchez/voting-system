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

ActiveRecord::Schema[7.0].define(version: 2025_07_02_222900) do
  create_table "performers", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_performers_on_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "zipcode", null: false
    t.string "password_digest", null: false
    t.integer "token_version", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.index ["email", "zipcode"], name: "index_users_on_email_and_zipcode", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "performer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["performer_id"], name: "index_votes_on_performer_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
    t.index ["user_id"], name: "index_votes_on_user_id_unique", unique: true
  end

  add_foreign_key "votes", "performers"
  add_foreign_key "votes", "users"
end
