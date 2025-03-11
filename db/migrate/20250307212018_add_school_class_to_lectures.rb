class AddSchoolClassToLectures < ActiveRecord::Migration[8.0]
  def change
    add_reference :lectures, :school_class, null: true, foreign_key: true
  end
end
