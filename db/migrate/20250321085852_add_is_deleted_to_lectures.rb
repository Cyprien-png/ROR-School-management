class AddIsDeletedToLectures < ActiveRecord::Migration[8.0]
  def change
    add_column :lectures, :isDeleted, :boolean, default: false
  end
end
