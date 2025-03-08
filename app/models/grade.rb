class Grade < ApplicationRecord
  belongs_to :examination
  belongs_to :student, class_name: 'Student'
  
  validates :value, presence: true, 
                   numericality: { 
                     greater_than_or_equal_to: 0.00,
                     less_than_or_equal_to: 9.99
                   }
  validates :examination_id, uniqueness: { scope: :student_id, message: "has already been graded for this student" }
  
  validate :examination_not_deleted
  validate :student_must_be_in_lecture_class
  
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
end
