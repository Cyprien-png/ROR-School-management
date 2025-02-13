class CreateDeans < ActiveRecord::Migration[8.0]
  def change
    create_table :deans do |t|
      t.timestamps
    end
  end
end
