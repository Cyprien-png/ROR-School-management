class Lecture < ApplicationRecord
  belongs_to :subject
  
  # Validations
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :week_day, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 6 }, if: -> { week_day.is_a?(Integer) }
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
  
  def end_time_after_start_time
    return if start_time.blank? || end_time.blank?
    
    if end_time <= start_time
      errors.add(:end_time, "must be after start time")
    end
  end
end
