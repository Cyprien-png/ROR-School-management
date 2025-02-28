class SchoolClass < ApplicationRecord
  belongs_to :teacher, class_name: 'Teacher'
  has_and_belongs_to_many :students, join_table: 'school_classes_students'
  
  validate :ensure_teacher_type
  
  private def ensure_teacher_type
    if teacher.present? && !teacher.is_a?(Teacher)
      errors.add(:teacher, "must be a Teacher, not a #{teacher.type}")
    end
  end
end
