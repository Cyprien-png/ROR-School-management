class CreateTrimesters < ActiveRecord::Migration[8.0]
  def change
    create_table :trimesters do |t|
      t.date :start_date
      t.date :end_date

      t.timestamps
    end
  end
end
