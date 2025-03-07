class Year < ApplicationRecord
  belongs_to :first_trimester
  belongs_to :second_trimester
  belongs_to :third_trimester
  belongs_to :fourth_trimester
end
