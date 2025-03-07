class AddSubjectToLectures < ActiveRecord::Migration[8.0]
  def change
    add_reference :lectures, :subject, null: false, foreign_key: true
  end
end
