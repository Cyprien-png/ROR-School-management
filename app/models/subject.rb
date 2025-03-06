class Subject < ApplicationRecord
  has_and_belongs_to_many :teachers, join_table: 'subjects_teachers'

  validates :name, presence: true, uniqueness: true
end
