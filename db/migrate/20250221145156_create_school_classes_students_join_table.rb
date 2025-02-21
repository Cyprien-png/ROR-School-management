class CreateSchoolClassesStudentsJoinTable < ActiveRecord::Migration[8.0]
  def change
    create_table :school_classes_students do |t|
      t.references :school_class, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :people }
    end
  end
end