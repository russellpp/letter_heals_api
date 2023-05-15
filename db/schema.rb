# frozen_string_literal: true

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

ActiveRecord::Schema[7.0].define(version: 20_230_515_073_335) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'plpgsql'

  create_table 'comments', force: :cascade do |t|
    t.string 'unique_id'
    t.string 'title'
    t.string 'body'
    t.boolean 'anonymous'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'messages', force: :cascade do |t|
    t.string 'unique_id'
    t.string 'title'
    t.string 'body'
    t.boolean 'anonymous'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'author'
    t.string 'recipient'
    t.index ['unique_id'], name: 'index_messages_on_unique_id', unique: true
  end

  create_table 'posts', force: :cascade do |t|
    t.string 'unique_id'
    t.string 'title'
    t.string 'body'
    t.string 'status'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'author'
    t.string 'reviewer'
    t.index ['unique_id'], name: 'index_posts_on_unique_id', unique: true
  end

  create_table 'users', force: :cascade do |t|
    t.string 'unique_id'
    t.string 'email'
    t.string 'phone_number'
    t.integer 'status'
    t.string 'name'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'jti'
    t.string 'profile_name'
    t.boolean 'verified'
    t.string 'role'
    t.string 'password_digest'
    t.index ['unique_id'], name: 'index_users_on_unique_id', unique: true
  end

  add_foreign_key 'messages', 'users', column: 'author', primary_key: 'unique_id'
  add_foreign_key 'messages', 'users', column: 'recipient', primary_key: 'unique_id'
  add_foreign_key 'posts', 'users', column: 'author', primary_key: 'unique_id'
  add_foreign_key 'posts', 'users', column: 'reviewer', primary_key: 'unique_id'
end
