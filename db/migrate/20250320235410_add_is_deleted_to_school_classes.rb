class AddIsDeletedToSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    add_column :school_classes, :isDeleted, :boolean, default: false
  end
end
