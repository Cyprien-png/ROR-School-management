class CreateJoinTableTeachersSubjects < ActiveRecord::Migration[8.0]
  def change
    create_table :subjects_teachers do |t|
      t.references :teacher, null: false, foreign_key: { to_table: :people }
      t.references :subject, null: false, foreign_key: true
      t.timestamps
      t.index [:teacher_id, :subject_id], unique: true
    end
  end
end
