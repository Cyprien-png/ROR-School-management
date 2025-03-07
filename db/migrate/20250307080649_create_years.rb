class CreateYears < ActiveRecord::Migration[8.0]
  def change
    create_table :years do |t|
      t.references :first_trimester, null: false, foreign_key: { to_table: :trimesters }
      t.references :second_trimester, null: false, foreign_key: { to_table: :trimesters }
      t.references :third_trimester, null: false, foreign_key: { to_table: :trimesters }
      t.references :fourth_trimester, null: false, foreign_key: { to_table: :trimesters }

      t.timestamps
    end
  end
end
