class AddIsDeletedToSubjects < ActiveRecord::Migration[8.0]
  def change
    add_column :subjects, :isDeleted, :boolean, default: false
  end
end
