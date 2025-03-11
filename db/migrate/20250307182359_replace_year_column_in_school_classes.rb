class ReplaceYearColumnInSchoolClasses < ActiveRecord::Migration[8.0]
  def change
    add_reference :school_classes, :year, null: true, foreign_key: true
    remove_column :school_classes, :year
  end
end
    # Add back the original year column
