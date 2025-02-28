class CreateSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    create_table :school_classes do |t|
      t.string :name, null: false
      t.integer :grade, null: false
      t.string :year, null: false

      t.timestamps
    end
  end
end
