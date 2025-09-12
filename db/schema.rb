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

ActiveRecord::Schema[8.0].define(version: 20_250_912_021_535) do
  # These are extensions that must be enabled in order to support this database
  enable_extension 'pg_catalog.plpgsql'
  enable_extension 'pg_trgm'
  enable_extension 'pgcrypto'

  create_table 'active_storage_attachments', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'name', null: false
    t.string 'record_type', null: false
    t.uuid 'record_id', null: false
    t.uuid 'blob_id', null: false
    t.datetime 'created_at', null: false
    t.index ['blob_id'], name: 'index_active_storage_attachments_on_blob_id'
    t.index %w[record_type record_id name blob_id], name: 'index_active_storage_attachments_uniqueness',
                                                    unique: true
  end

  create_table 'active_storage_blobs', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'key', null: false
    t.string 'filename', null: false
    t.string 'content_type'
    t.text 'metadata'
    t.string 'service_name', null: false
    t.bigint 'byte_size', null: false
    t.string 'checksum'
    t.datetime 'created_at', null: false
    t.index ['key'], name: 'index_active_storage_blobs_on_key', unique: true
  end

  create_table 'active_storage_variant_records', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.uuid 'blob_id', null: false
    t.string 'variation_digest', null: false
    t.index %w[blob_id variation_digest], name: 'index_active_storage_variant_records_uniqueness', unique: true
  end

  create_table 'document_editors', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.uuid 'document_id', null: false
    t.uuid 'user_id', null: false
    t.integer 'role', default: 0, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['document_id'], name: 'index_document_editors_on_document_id'
    t.index ['user_id'], name: 'index_document_editors_on_user_id'
  end

  create_table 'documents', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'title'
    t.text 'markdown'
    t.uuid 'user_id', null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.string 'slug'
    t.index ['slug'], name: 'index_documents_on_slug', unique: true
    t.index ['user_id'], name: 'index_documents_on_user_id'
  end

  create_table 'friendly_id_slugs', force: :cascade do |t|
    t.string 'slug', null: false
    t.integer 'sluggable_id', null: false
    t.string 'sluggable_type', limit: 50
    t.string 'scope'
    t.datetime 'created_at'
    t.index %w[slug sluggable_type scope], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type_and_scope',
                                           unique: true
    t.index %w[slug sluggable_type], name: 'index_friendly_id_slugs_on_slug_and_sluggable_type'
    t.index %w[sluggable_type sluggable_id], name: 'index_friendly_id_slugs_on_sluggable_type_and_sluggable_id'
  end

  create_table 'page_views', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'pageviewable_type'
    t.uuid 'pageviewable_id'
    t.uuid 'user_id'
    t.string 'controller_name'
    t.string 'action_name'
    t.string 'view_name'
    t.string 'request_hash'
    t.string 'session_hash'
    t.string 'ip_address'
    t.text 'params'
    t.string 'referrer'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index %w[controller_name action_name], name: 'index_page_views_on_controller_name_and_action_name'
    t.index ['created_at'], name: 'index_page_views_on_created_at'
    t.index %w[pageviewable_type pageviewable_id], name: 'index_page_views_on_pageviewable_type_and_pageviewable_id'
    t.index ['request_hash'], name: 'index_page_views_on_request_hash'
    t.index ['user_id'], name: 'index_page_views_on_user_id'
  end

  create_table 'users', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'email', default: '', null: false
    t.string 'encrypted_password', default: '', null: false
    t.string 'reset_password_token'
    t.datetime 'reset_password_sent_at'
    t.datetime 'remember_created_at'
    t.string 'first_name', null: false
    t.string 'last_name', null: false
    t.integer 'role', default: 1, null: false
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
    t.index ['email'], name: 'index_users_on_email', unique: true
    t.index ['reset_password_token'], name: 'index_users_on_reset_password_token', unique: true
    t.index ['role'], name: 'index_users_on_role'
  end

  create_table 'versions', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'whodunnit'
    t.datetime 'created_at'
    t.string 'item_id', null: false
    t.string 'item_type', null: false
    t.string 'event', null: false
    t.text 'object'
    t.index %w[item_type item_id], name: 'index_versions_on_item_type_and_item_id'
  end

  add_foreign_key 'active_storage_attachments', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'active_storage_variant_records', 'active_storage_blobs', column: 'blob_id'
  add_foreign_key 'document_editors', 'documents'
  add_foreign_key 'document_editors', 'users'
  add_foreign_key 'documents', 'users'
end
