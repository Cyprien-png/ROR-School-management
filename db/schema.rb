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

ActiveRecord::Schema[8.0].define(version: 2025_03_08_103240) do
  create_table "examinations", force: :cascade do |t|
    t.string "title"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "lecture_id"
    t.index ["lecture_id"], name: "index_examinations_on_lecture_id"
  end

  create_table "lectures", force: :cascade do |t|
    t.time "start_time"
    t.time "end_time"
    t.integer "week_day"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "subject_id", null: false
    t.integer "teacher_id", null: false
    t.integer "school_class_id"
    t.index ["school_class_id"], name: "index_lectures_on_school_class_id"
    t.index ["subject_id"], name: "index_lectures_on_subject_id"
    t.index ["teacher_id"], name: "index_lectures_on_teacher_id"
  end

  create_table "lectures_trimesters", id: false, force: :cascade do |t|
    t.integer "lecture_id", null: false
    t.integer "trimester_id", null: false
    t.index ["lecture_id", "trimester_id"], name: "index_lectures_trimesters_on_lecture_id_and_trimester_id"
    t.index ["trimester_id", "lecture_id"], name: "index_lectures_trimesters_on_trimester_id_and_lecture_id"
  end

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
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "teacher_id", null: false
    t.integer "year_id"
    t.index ["teacher_id"], name: "index_school_classes_on_teacher_id"
    t.index ["year_id"], name: "index_school_classes_on_year_id"
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
    t.boolean "isDeleted", default: false
  end

  create_table "subjects_teachers", force: :cascade do |t|
    t.integer "teacher_id", null: false
    t.integer "subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subject_id"], name: "index_subjects_teachers_on_subject_id"
    t.index ["teacher_id", "subject_id"], name: "index_subjects_teachers_on_teacher_id_and_subject_id", unique: true
    t.index ["teacher_id"], name: "index_subjects_teachers_on_teacher_id"
  end

  create_table "trimesters", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "years", force: :cascade do |t|
    t.integer "first_trimester_id", null: false
    t.integer "second_trimester_id", null: false
    t.integer "third_trimester_id", null: false
    t.integer "fourth_trimester_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "isDeleted", default: false
    t.index ["first_trimester_id"], name: "index_years_on_first_trimester_id"
    t.index ["fourth_trimester_id"], name: "index_years_on_fourth_trimester_id"
    t.index ["second_trimester_id"], name: "index_years_on_second_trimester_id"
    t.index ["third_trimester_id"], name: "index_years_on_third_trimester_id"
  end

  add_foreign_key "examinations", "lectures"
  add_foreign_key "lectures", "people", column: "teacher_id"
  add_foreign_key "lectures", "school_classes"
  add_foreign_key "lectures", "subjects"
  add_foreign_key "school_classes", "people", column: "teacher_id"
  add_foreign_key "school_classes", "years"
  add_foreign_key "school_classes_students", "people", column: "student_id"
  add_foreign_key "school_classes_students", "school_classes"
  add_foreign_key "subjects_teachers", "people", column: "teacher_id"
  add_foreign_key "subjects_teachers", "subjects"
  add_foreign_key "years", "trimesters", column: "first_trimester_id"
  add_foreign_key "years", "trimesters", column: "fourth_trimester_id"
  add_foreign_key "years", "trimesters", column: "second_trimester_id"
  add_foreign_key "years", "trimesters", column: "third_trimester_id"
end
