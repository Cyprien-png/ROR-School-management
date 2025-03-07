class CreateLectures < ActiveRecord::Migration[8.0]
  def change
    create_table :lectures do |t|
      t.time :start_time
      t.time :end_time
      t.integer :week_day

      t.timestamps
    end
  end
end
