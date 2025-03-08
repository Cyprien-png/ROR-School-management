class CreateGrades < ActiveRecord::Migration[8.0]
  def change
    create_table :grades do |t|
      t.decimal :value, precision: 3, scale: 2
      t.references :examination, null: false, foreign_key: true
      t.references :student, null: false, foreign_key: { to_table: :people }

      t.timestamps
    end
  end
end
