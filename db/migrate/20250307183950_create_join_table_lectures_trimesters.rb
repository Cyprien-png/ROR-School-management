class CreateJoinTableLecturesTrimesters < ActiveRecord::Migration[8.0]
  def change
    create_join_table :lectures, :trimesters do |t|
      t.index [:lecture_id, :trimester_id]
      t.index [:trimester_id, :lecture_id]
    end
  end
end
