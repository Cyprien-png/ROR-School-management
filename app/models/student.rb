class Student < Person
  enum :status, {
    in_formation: 0,
    stopped: 1,
    finished: 2
  }

  has_and_belongs_to_many :school_classes, join_table: 'school_classes_students', before_add: :validate_unique_year

  has_many :grades, dependent: :destroy

  validates :status, presence: true

  private

  def validate_unique_year(school_class)
    if school_classes.where(year_id: school_class.year_id).exists?
      year = school_class.year
      year_range = "#{year.first_trimester.start_date.year}-#{year.fourth_trimester.end_date.year}"
      errors.add(:base, "Cannot be assigned to multiple school classes in the same academic year (#{year_range})")
      raise ActiveRecord::Rollback, "Student already has a class in this academic year"
    end
  end
end
