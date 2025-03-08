class AddIsDeletedToGrades < ActiveRecord::Migration[8.0]
  def change
    add_column :grades, :isDeleted, :boolean, default: false
  end
end
