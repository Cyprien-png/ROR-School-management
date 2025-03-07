class AddIsDeletedToYears < ActiveRecord::Migration[8.0]
  def change
    add_column :years, :isDeleted, :boolean, default: false
  end
end
