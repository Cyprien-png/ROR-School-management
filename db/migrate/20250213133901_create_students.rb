class CreateStudents < ActiveRecord::Migration[8.0]
  def change
    create_table :students do |t|
      t.integer :status, null: false

      t.timestamps
    end
  end
end
