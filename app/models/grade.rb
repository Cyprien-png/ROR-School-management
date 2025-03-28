class Grade < ApplicationRecord
  belongs_to :examination
  belongs_to :student, class_name: 'Student'
  
  attr_accessor :current_teacher
  
  validates :value, presence: true, 
                   numericality: { 
                     greater_than_or_equal_to: 1.00,
                     less_than_or_equal_to: 6.00,
                     message: "must be between 1.00 and 6.00"
                   }
  validates :student_id, uniqueness: { 
    scope: :examination_id, 
    message: "already has a grade for this examination" 
  }
  
  validate :examination_not_deleted
  validate :student_must_be_in_lecture_class
  validate :teacher_must_teach_subject
  
  # Add default scope to exclude soft deleted records
  default_scope { where(isDeleted: false) }
  # Add scope to include soft deleted records when needed
  scope :with_deleted, -> { unscope(where: :isDeleted) }

  # Soft delete method
  def soft_delete
    update_column(:isDeleted, true)
  end
  
  private
  
  def examination_not_deleted
    if examination&.isDeleted?
      errors.add(:examination, "cannot be a deleted examination")
    end
  end
  
  def student_must_be_in_lecture_class
    return if examination.blank? || student.blank?
    
    unless examination.lecture.school_class.students.include?(student)
      errors.add(:student, "must be in the lecture's class")
    end
  end

  def teacher_must_teach_subject
    return if examination.blank? || !current_teacher.is_a?(Teacher)
    
    unless current_teacher.subjects.include?(examination.lecture.subject)
      errors.add(:examination, "must be for a subject you teach")
    end
  end
end
