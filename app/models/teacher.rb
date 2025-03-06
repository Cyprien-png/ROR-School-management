class Teacher < Person
  has_many :school_classes
  has_and_belongs_to_many :subjects, join_table: 'subjects_teachers'

  validates :iban, presence: true
end
