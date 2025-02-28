class AddIsDeletedToPeople < ActiveRecord::Migration[8.0]
  def change
    add_column :people, :isDeleted, :boolean, default: false
  end
end
