class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :lastname, null: false
      t.string :firstname, null: false
      t.string :phone_number
      t.string :type

      t.timestamps
    end
  end
end
