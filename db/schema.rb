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

ActiveRecord::Schema[8.0].define(version: 2025_03_06_135611) do
  create_table "people", force: :cascade do |t|
    t.string "lastname", null: false
    t.string "firstname", null: false
    t.string "phone_number"
    t.string "type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "iban"
    t.integer "status"
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.boolean "isDeleted", default: false
    t.index ["email"], name: "index_people_on_email", unique: true
    t.index ["reset_password_token"], name: "index_people_on_reset_password_token", unique: true
  end

  create_table "school_classes", force: :cascade do |t|
    t.string "name", null: false
    t.integer "grade", null: false
    t.string "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "teacher_id", null: false
    t.index ["teacher_id"], name: "index_school_classes_on_teacher_id"
  end

  create_table "school_classes_students", force: :cascade do |t|
    t.integer "school_class_id", null: false
    t.integer "student_id", null: false
    t.index ["school_class_id"], name: "index_school_classes_students_on_school_class_id"
    t.index ["student_id"], name: "index_school_classes_students_on_student_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "school_classes", "people", column: "teacher_id"
  add_foreign_key "school_classes_students", "people", column: "student_id"
  add_foreign_key "school_classes_students", "school_classes"
end
