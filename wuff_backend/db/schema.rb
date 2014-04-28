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

ActiveRecord::Schema.define(version: 20140428000920) do

  create_table "events", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "location"
    t.integer  "admin"
    t.text     "party_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "time"
    t.integer  "scheduler_job_id"
  end

  create_table "groups", force: true do |t|
    t.string   "name"
    t.text     "description"
    t.text     "user_list"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "name"
    t.string   "email"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "password_digest"
    t.string   "remember_token"
    t.text     "event_list"
    t.text     "notification_list"
    t.text     "friend_list"
    t.text     "group_list"
    t.string   "fb_id"
    t.text     "device_tokens"
  end

  add_index "users", ["device_tokens"], name: "index_users_on_device_tokens"
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["fb_id"], name: "index_users_on_fb_id"
  add_index "users", ["remember_token"], name: "index_users_on_remember_token"

end
