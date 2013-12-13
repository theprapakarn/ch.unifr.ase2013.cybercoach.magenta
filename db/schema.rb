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

ActiveRecord::Schema.define(version: 20131104081410) do

  create_table "activities", force: true do |t|
    t.string   "reference"
    t.string   "name"
    t.integer  "user_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "sport"
    t.integer  "entry_id"
    t.integer  "owner_id"
    t.boolean  "is_proxy"
    t.string   "place"
    t.string   "comment"
    t.integer  "reference_activity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "bids", force: true do |t|
    t.decimal  "price"
    t.integer  "user_id"
    t.integer  "car_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "bids", ["car_id"], name: "index_bids_on_car_id", using: :btree

  create_table "cars", force: true do |t|
    t.string   "model"
    t.text     "brand"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.decimal  "price"
  end

  create_table "entries", force: true do |t|
    t.string   "reference"
    t.string   "public_visible"
    t.integer  "user_id"
    t.integer  "subscription_id"
    t.boolean  "is_proxy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants", force: true do |t|
    t.string   "reference"
    t.string   "public_visible"
    t.integer  "user_id"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "gender"
    t.string   "birth_date"
    t.boolean  "is_proxy"
    t.datetime "date_created"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "participants_to_partnerships", force: true do |t|
    t.integer  "participant_id"
    t.integer  "partnership_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "partnerships", force: true do |t|
    t.string   "reference"
    t.string   "public_visible"
    t.integer  "user_id"
    t.integer  "first_participant_id"
    t.integer  "second_participant_id"
    t.boolean  "first_participant_confirmed"
    t.boolean  "second_participant_confirmed"
    t.datetime "date_created"
    t.boolean  "is_proxy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "sports", force: true do |t|
    t.string   "reference"
    t.string   "name"
    t.boolean  "is_proxy"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "subscriptions", force: true do |t|
    t.string   "reference"
    t.string   "public_visible"
    t.integer  "sport_id"
    t.integer  "user_id"
    t.integer  "entry_id"
    t.boolean  "is_proxy"
    t.datetime "subscribed_created"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "participant_id"
    t.integer  "partnership_id"
  end

  add_index "subscriptions", ["participant_id"], name: "index_subscriptions_on_participant_id", using: :btree
  add_index "subscriptions", ["partnership_id"], name: "index_subscriptions_on_partnership_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "username"
    t.string   "basic_authorization"
    t.string   "email"
    t.string   "email_password"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.string   "password_digest"
  end

  add_index "users", ["remember_token"], name: "index_users_on_remember_token", using: :btree

end
