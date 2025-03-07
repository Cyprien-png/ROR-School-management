class Lecture < ApplicationRecord
  belongs_to :subject
  belongs_to :teacher
  belongs_to :school_class
  has_and_belongs_to_many :trimesters
  
  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :week_day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }, if: -> { week_day.is_a?(Integer) }
  validates :trimesters, presence: true
  validates :teacher, presence: true
  validates :school_class, presence: true
  validate :teacher_must_teach_subject
  validate :end_time_after_start_time
  
  # Enum for week days (0: Sunday, 1: Monday, ..., 6: Saturday)
  enum :week_day, {
      monday: 0,
      tuesday: 1,
      wednesday: 2,
      thursday: 3,
      friday: 4,
      saturday: 5,
      sunday: 6
  }
  
  private
  
  def teacher_must_teach_subject
    return if teacher.blank? || subject.blank?
    
    unless teacher.subjects.include?(subject)
      errors.add(:teacher, "must teach this subject")
    end
  end
  
  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
