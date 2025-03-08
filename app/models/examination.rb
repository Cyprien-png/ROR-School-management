class Examination < ApplicationRecord
  belongs_to :lecture, optional: true
  has_many :grades, dependent: :destroy
  
  validates :title, presence: true
  validates :date, presence: true
  validate :date_matches_lecture_weekday, if: -> { lecture.present? && date.present? }
  
  # Add default scope to exclude soft deleted records
  default_scope { where(isDeleted: false) }
  # Add scope to include soft deleted records when needed
  scope :with_deleted, -> { unscope(where: :isDeleted) }

  # Soft delete method
  def soft_delete
    update_column(:isDeleted, true)
  end
  
  private
  
  def date_matches_lecture_weekday
    # Get all trimesters dates ranges
    trimester_ranges = lecture.trimesters.map { |t| t.start_date..t.end_date }
    
    # Check if the date falls within any of the trimesters
    unless trimester_ranges.any? { |range| range.cover?(date) }
      errors.add(:date, "must fall within one of the lecture's trimesters")
      return
    end
    
    # Convert lecture.week_day (string like "monday") to Ruby's wday number (0=Sunday, 1=Monday, etc)
    lecture_wday = Date::DAYNAMES.map(&:downcase).index(lecture.week_day)
    
    # Check if the examination date matches the lecture's weekday
    unless date.wday == lecture_wday
      errors.add(:date, "must be on a #{lecture.week_day.capitalize} to match the lecture's schedule")
    end
  end
end
