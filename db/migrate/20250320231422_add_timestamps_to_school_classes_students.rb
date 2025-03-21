class AddTimestampsToSchoolClassesStudents < ActiveRecord::Migration[8.0]
  def change
    add_timestamps :school_classes_students, null: true
    
    # Update existing records with the current timestamp
    now = Time.current
    execute <<-SQL
      UPDATE school_classes_students
      SET created_at = '#{now}',
          updated_at = '#{now}'
    SQL
    
    # Make the timestamp columns not nullable
    change_column_null :school_classes_students, :created_at, false
    change_column_null :school_classes_students, :updated_at, false
  end
end
