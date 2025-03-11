class Student < Person
  enum :status, {
    in_formation: 0,
    stopped: 1,
    finished: 2
  }

  has_and_belongs_to_many :school_classes, join_table: 'school_classes_students'
  has_many :grades, dependent: :destroy

  validates :status, presence: true
  validate :validate_unique_year_per_school_class

  private

  def validate_unique_year_per_school_class
    year_ids = school_classes.map(&:year_id)
    duplicate_years = year_ids.select { |year_id| year_ids.count(year_id) > 1 }.uniq
    
    if duplicate_years.any?
      duplicate_years.each do |year_id|
        year = Year.find(year_id)
        year_range = "#{year.first_trimester.start_date.year}-#{year.fourth_trimester.end_date.year}"
        errors.add(:base, "Cannot be assigned to multiple school classes in the same academic year (#{year_range})")
      end
    end
  end
end
