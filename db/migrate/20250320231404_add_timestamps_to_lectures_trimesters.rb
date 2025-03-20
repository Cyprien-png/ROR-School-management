class AddTimestampsToLecturesTrimesters < ActiveRecord::Migration[8.0]
  def change
    add_timestamps :lectures_trimesters, null: true
    
    # Update existing records with the current timestamp
    now = Time.current
    execute <<-SQL
      UPDATE lectures_trimesters
      SET created_at = '#{now}',
          updated_at = '#{now}'
    SQL
    
    # Make the timestamp columns not nullable
    change_column_null :lectures_trimesters, :created_at, false
    change_column_null :lectures_trimesters, :updated_at, false
  end
end
