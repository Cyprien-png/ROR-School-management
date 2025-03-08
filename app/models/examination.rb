class Examination < ApplicationRecord
  belongs_to :lecture, optional: true
  
  validates :title, presence: true
  validates :date, presence: true
end
