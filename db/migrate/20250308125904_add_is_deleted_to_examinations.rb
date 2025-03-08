class AddIsDeletedToExaminations < ActiveRecord::Migration[8.0]
  def change
    add_column :examinations, :isDeleted, :boolean, default: false
  end
end
