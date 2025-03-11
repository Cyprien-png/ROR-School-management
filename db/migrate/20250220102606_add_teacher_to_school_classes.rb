class AddTeacherToSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    add_reference :school_classes, :teacher, null: false, foreign_key: { to_table: :people }
  end
end
