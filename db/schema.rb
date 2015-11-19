# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20151119071258) do

  create_table "booking_days", force: :cascade do |t|
    t.string   "day"
    t.date     "date"
    t.integer  "room_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "booking_days", ["room_id"], name: "index_booking_days_on_room_id"

  create_table "booking_times", force: :cascade do |t|
    t.time     "begin"
    t.time     "end"
    t.string   "status"
    t.integer  "booking_day_id"
    t.integer  "user_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "booking_times", ["booking_day_id"], name: "index_booking_times_on_booking_day_id"
  add_index "booking_times", ["user_id"], name: "index_booking_times_on_user_id"

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer  "priority",   default: 0, null: false
    t.integer  "attempts",   default: 0, null: false
    t.text     "handler",                null: false
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "delayed_jobs", ["priority", "run_at"], name: "delayed_jobs_priority"

  create_table "institutions", force: :cascade do |t|
    t.string   "name"
    t.string   "domain"
    t.string   "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rooms", force: :cascade do |t|
    t.string   "internal_name"
    t.string   "alias"
    t.string   "description"
    t.integer  "capacity"
    t.boolean  "is_generated"
    t.integer  "institution_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "rooms", ["institution_id"], name: "index_rooms_on_institution_id"

  create_table "users", force: :cascade do |t|
    t.string   "email"
    t.string   "password_digest"
    t.string   "remember_digest"
    t.string   "activation_token"
    t.boolean  "is_verified"
    t.string   "reset_token"
    t.datetime "reset_expire"
    t.integer  "institution_id"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "users", ["institution_id"], name: "index_users_on_institution_id"

end
