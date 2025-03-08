class Student < Person
  enum :status, {
    in_formation: 0,
    stopped: 1,
    finished: 2
  }

  has_and_belongs_to_many :school_classes, join_table: 'school_classes_students'
  has_many :grades, dependent: :destroy

  validates :status, presence: true
end
