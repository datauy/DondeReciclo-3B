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

ActiveRecord::Schema.define(version: 2022_09_17_154557) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "postgis"

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
    t.integer "role"
    t.bigint "country_id"
    t.index ["country_id"], name: "index_admin_users_on_country_id"
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
    t.boolean "hidden", default: false
    t.geography "latlon", limit: {:srid=>4326, :type=>"st_point", :geographic=>true}
    t.text "information"
    t.boolean "custom_icon_active"
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
    t.geometry "geometry", limit: {:srid=>0, :type=>"multi_polygon"}
    t.string "contact"
    t.geometry "center", limit: {:srid=>0, :type=>"st_point"}
    t.string "code"
    t.string "locale"
    t.decimal "lat"
    t.decimal "lon"
  end

  create_table "dimension_relations", force: :cascade do |t|
    t.bigint "dimension_id", null: false
    t.bigint "country_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["country_id"], name: "index_dimension_relations_on_country_id"
    t.index ["dimension_id"], name: "index_dimension_relations_on_dimension_id"
  end

  create_table "dimensions", force: :cascade do |t|
    t.string "name"
    t.text "information"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "location_relations", force: :cascade do |t|
    t.bigint "location_id", null: false
    t.bigint "program_id"
    t.bigint "sub_program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["location_id"], name: "index_location_relations_on_location_id"
    t.index ["program_id"], name: "index_location_relations_on_program_id"
    t.index ["sub_program_id"], name: "index_location_relations_on_sub_program_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.geometry "geometry", limit: {:srid=>0, :type=>"multi_polygon"}
    t.integer "loc_type"
    t.string "code"
  end

  create_table "material_translations", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.text "information"
    t.index ["locale"], name: "index_material_translations_on_locale"
    t.index ["material_id"], name: "index_material_translations_on_material_id"
  end

  create_table "materials", force: :cascade do |t|
    t.string "name"
    t.text "information"
    t.string "video"
    t.string "color"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "dimension_id", default: 1, null: false
    t.index ["dimension_id"], name: "index_materials_on_dimension_id"
  end

  create_table "materials_programs", id: false, force: :cascade do |t|
    t.bigint "program_id", null: false
    t.bigint "material_id", null: false
    t.index ["program_id", "material_id"], name: "index_materials_programs_on_program_id_and_material_id"
  end

  create_table "materials_relations", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.bigint "predefined_search_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "report_id"
    t.bigint "dimension_id"
    t.index ["dimension_id"], name: "index_materials_relations_on_dimension_id"
    t.index ["material_id"], name: "index_materials_relations_on_material_id"
    t.index ["predefined_search_id"], name: "index_materials_relations_on_predefined_search_id"
    t.index ["report_id"], name: "index_materials_relations_on_report_id"
  end

  create_table "materials_sub_programs", id: false, force: :cascade do |t|
    t.bigint "sub_program_id", null: false
    t.bigint "material_id", null: false
    t.index ["sub_program_id", "material_id"], name: "index_materials_sub_programs_on_sub_program_id_and_material_id"
  end

  create_table "news", force: :cascade do |t|
    t.string "title"
    t.text "information"
    t.string "video"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "summary"
    t.bigint "country_id"
    t.index ["country_id"], name: "index_news_on_country_id"
  end

  create_table "oauth_access_grants", force: :cascade do |t|
    t.bigint "resource_owner_id", null: false
    t.bigint "application_id", null: false
    t.string "token", null: false
    t.integer "expires_in", null: false
    t.text "redirect_url"
    t.datetime "created_at", null: false
    t.datetime "revoked_at"
    t.string "scopes", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_grants_on_application_id"
    t.index ["resource_owner_id"], name: "index_oauth_access_grants_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_grants_on_token", unique: true
  end

  create_table "oauth_access_tokens", force: :cascade do |t|
    t.bigint "resource_owner_id"
    t.bigint "application_id"
    t.string "token", null: false
    t.string "refresh_token"
    t.integer "expires_in"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.string "scopes"
    t.string "previous_refresh_token", default: "", null: false
    t.index ["application_id"], name: "index_oauth_access_tokens_on_application_id"
    t.index ["refresh_token"], name: "index_oauth_access_tokens_on_refresh_token", unique: true
    t.index ["resource_owner_id"], name: "index_oauth_access_tokens_on_resource_owner_id"
    t.index ["token"], name: "index_oauth_access_tokens_on_token", unique: true
  end

  create_table "oauth_applications", force: :cascade do |t|
    t.string "name", null: false
    t.string "uid", null: false
    t.string "secret", null: false
    t.text "redirect_uri", null: false
    t.string "scopes", default: "", null: false
    t.boolean "confidential", default: true, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["uid"], name: "index_oauth_applications_on_uid", unique: true
  end

  create_table "predefined_searches", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "dimension_id", default: 1, null: false
    t.index ["country_id"], name: "index_predefined_searches_on_country_id"
    t.index ["dimension_id"], name: "index_predefined_searches_on_dimension_id"
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
    t.bigint "country_id", default: 1, null: false
    t.bigint "tag_id"
    t.index ["country_id"], name: "index_programs_on_country_id"
    t.index ["tag_id"], name: "index_programs_on_tag_id"
  end

  create_table "programs_wastes", id: false, force: :cascade do |t|
    t.bigint "waste_id", null: false
    t.bigint "program_id", null: false
    t.index ["program_id", "waste_id"], name: "index_programs_wastes_on_program_id_and_waste_id"
  end

  create_table "reports", force: :cascade do |t|
    t.bigint "sub_program_id"
    t.string "subject"
    t.text "comment"
    t.bigint "country_id", null: false
    t.string "neighborhood"
    t.string "address"
    t.integer "weight"
    t.boolean "donation"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id", null: false
    t.geometry "coords", limit: {:srid=>0, :type=>"st_point"}
    t.index ["country_id"], name: "index_reports_on_country_id"
    t.index ["sub_program_id"], name: "index_reports_on_sub_program_id"
    t.index ["user_id"], name: "index_reports_on_user_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.integer "weekday"
    t.time "start"
    t.time "end"
    t.string "desc"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "closed"
  end

  create_table "schedules_zones", id: false, force: :cascade do |t|
    t.bigint "zone_id", null: false
    t.bigint "schedule_id", null: false
    t.index ["zone_id", "schedule_id"], name: "index_schedules_zones_on_zone_id_and_schedule_id"
  end

  create_table "sub_programs", force: :cascade do |t|
    t.bigint "program_id", null: false
    t.string "name"
    t.text "reception_conditions"
    t.text "receives"
    t.text "receives_no"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "material_id", default: 1, null: false
    t.string "city"
    t.string "address"
    t.string "email"
    t.string "phone"
    t.string "full_name"
    t.string "action_link"
    t.string "action_title"
    t.index ["material_id"], name: "index_sub_programs_on_material_id"
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

  create_table "tag_relations", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "program_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["program_id"], name: "index_tag_relations_on_program_id"
    t.index ["tag_id"], name: "index_tag_relations_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.integer "section"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.string "sex"
    t.string "state"
    t.string "neighborhood"
    t.integer "age"
    t.bigint "country_id", default: 1, null: false
    t.index ["country_id"], name: "index_users_on_country_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "waste_translations", force: :cascade do |t|
    t.bigint "waste_id", null: false
    t.string "locale", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "name"
    t.text "deposition"
    t.index ["locale"], name: "index_waste_translations_on_locale"
    t.index ["waste_id"], name: "index_waste_translations_on_waste_id"
  end

  create_table "wastes", force: :cascade do |t|
    t.bigint "material_id"
    t.string "name"
    t.text "deposition"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["material_id"], name: "index_wastes_on_material_id"
  end

  create_table "wastes_relations", force: :cascade do |t|
    t.bigint "waste_id", null: false
    t.bigint "predefined_search_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "report_id"
    t.index ["predefined_search_id"], name: "index_wastes_relations_on_predefined_search_id"
    t.index ["report_id"], name: "index_wastes_relations_on_report_id"
    t.index ["waste_id"], name: "index_wastes_relations_on_waste_id"
  end

  create_table "zones", force: :cascade do |t|
    t.bigint "sub_program_id", null: false
    t.bigint "location_id", null: false
    t.boolean "is_route"
    t.integer "pick_up_type"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.text "information"
    t.index ["location_id"], name: "index_zones_on_location_id"
    t.index ["sub_program_id"], name: "index_zones_on_sub_program_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "admin_users", "countries"
  add_foreign_key "containers", "container_types"
  add_foreign_key "containers", "sub_programs"
  add_foreign_key "dimension_relations", "countries"
  add_foreign_key "dimension_relations", "dimensions"
  add_foreign_key "location_relations", "locations"
  add_foreign_key "location_relations", "programs"
  add_foreign_key "location_relations", "sub_programs"
  add_foreign_key "materials", "dimensions"
  add_foreign_key "materials_relations", "dimensions"
  add_foreign_key "materials_relations", "materials"
  add_foreign_key "materials_relations", "predefined_searches"
  add_foreign_key "materials_relations", "reports"
  add_foreign_key "news", "countries"
  add_foreign_key "oauth_access_grants", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_grants", "users", column: "resource_owner_id"
  add_foreign_key "oauth_access_tokens", "oauth_applications", column: "application_id"
  add_foreign_key "oauth_access_tokens", "users", column: "resource_owner_id"
  add_foreign_key "predefined_searches", "countries"
  add_foreign_key "predefined_searches", "dimensions"
  add_foreign_key "products", "materials"
  add_foreign_key "programs", "countries"
  add_foreign_key "programs", "tags"
  add_foreign_key "reports", "countries"
  add_foreign_key "reports", "sub_programs"
  add_foreign_key "reports", "users"
  add_foreign_key "sub_programs", "materials"
  add_foreign_key "sub_programs", "programs"
  add_foreign_key "supporters", "programs"
  add_foreign_key "tag_relations", "programs"
  add_foreign_key "tag_relations", "tags"
  add_foreign_key "users", "countries"
  add_foreign_key "wastes", "materials"
  add_foreign_key "wastes_relations", "predefined_searches"
  add_foreign_key "wastes_relations", "reports"
  add_foreign_key "wastes_relations", "wastes"
  add_foreign_key "zones", "locations"
  add_foreign_key "zones", "sub_programs"
end
