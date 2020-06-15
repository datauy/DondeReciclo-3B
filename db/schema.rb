# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_06_12_183354) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "container_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "containers", force: :cascade do |t|
    t.bigint "sub_program_id", null: false
    t.string "external_id"
    t.decimal "latitude"
    t.decimal "longitude"
    t.string "site"
    t.string "address"
    t.string "location"
    t.string "state"
    t.string "site_type"
    t.boolean "public_site"
    t.bigint "container_type_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["container_type_id"], name: "index_containers_on_container_type_id"
    t.index ["latitude", "longitude"], name: "index_containers_on_latitude_and_longitude"
    t.index ["sub_program_id"], name: "index_containers_on_sub_program_id"
  end

  create_table "containers_schedules", id: false, force: :cascade do |t|
    t.bigint "container_id", null: false
    t.bigint "schedule_id", null: false
    t.index ["container_id", "schedule_id"], name: "index_containers_schedules_on_container_id_and_schedule_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "materials", force: :cascade do |t|
    t.string "name"
    t.text "information"
    t.string "video"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "predefined_search"
  end

  create_table "materials_programs", id: false, force: :cascade do |t|
    t.bigint "program_id", null: false
    t.bigint "material_id", null: false
  end

  create_table "materials_relations", force: :cascade do |t|
    t.bigint "materials_id", null: false
    t.bigint "predefined_searches_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["materials_id"], name: "index_materials_relations_on_materials_id"
    t.index ["predefined_searches_id"], name: "index_materials_relations_on_predefined_searches_id"
  end

  create_table "materials_sub_programs", primary_key: ["material_id", "sub_program_id"], force: :cascade do |t|
    t.bigint "sub_program_id", null: false
    t.bigint "material_id", null: false
    t.index ["sub_program_id", "material_id"], name: "index_materials_sub_programs_on_sub_program_id_and_material_id"
  end

  create_table "predefined_searches", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_predefined_searches_on_country_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.text "information"
    t.string "video"
    t.integer "barcode"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "material_id", null: false
    t.index ["material_id"], name: "index_products_on_material_id"
  end

  create_table "products_wastes", id: false, force: :cascade do |t|
    t.bigint "product_id", null: false
    t.bigint "waste_id", null: false
    t.index ["product_id", "waste_id"], name: "index_products_wastes_on_product_id_and_waste_id"
  end

  create_table "programs", force: :cascade do |t|
    t.string "name"
    t.text "responsable"
    t.string "responsable_url"
    t.string "more_info"
    t.text "reception_conditions"
    t.string "contact"
    t.text "information"
    t.text "benefits"
    t.text "lifecycle"
    t.text "receives"
    t.text "receives_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "shortname"
  end

  create_table "programs_wastes", id: false, force: :cascade do |t|
    t.bigint "waste_id", null: false
    t.bigint "program_id", null: false
    t.index ["program_id", "waste_id"], name: "index_programs_wastes_on_program_id_and_waste_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "weekday"
    t.time "start"
    t.time "end"
    t.string "desc"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "sub_programs", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.string "name"
    t.text "reception_conditions"
    t.text "receives"
    t.text "receives_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["program_id"], name: "index_sub_programs_on_program_id"
  end

  create_table "sub_programs_users", id: false, force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "sub_program_id", null: false
    t.index ["user_id", "sub_program_id"], name: "index_sub_programs_users_on_user_id_and_sub_program_id"
  end

  create_table "sub_programs_wastes", id: false, force: :cascade do |t|
    t.bigint "waste_id", null: false
    t.bigint "sub_program_id", null: false
    t.index ["sub_program_id", "waste_id"], name: "index_sub_programs_wastes_on_sub_program_id_and_waste_id"
  end

  create_table "supporters", force: :cascade do |t|
    t.string "name"
    t.string "url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "program_id", null: false
    t.index ["program_id"], name: "index_supporters_on_program_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "wastes", force: :cascade do |t|
    t.bigint "material_id"
    t.string "name"
    t.text "deposition"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "predefined_search"
    t.index ["material_id"], name: "index_wastes_on_material_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "containers", "container_types"
  add_foreign_key "containers", "sub_programs"
  add_foreign_key "materials_relations", "materials", column: "materials_id"
  add_foreign_key "materials_relations", "predefined_searches", column: "predefined_searches_id"
  add_foreign_key "predefined_searches", "countries"
  add_foreign_key "products", "materials"
  add_foreign_key "sub_programs", "programs"
  add_foreign_key "supporters", "programs"
  add_foreign_key "wastes", "materials"
end
