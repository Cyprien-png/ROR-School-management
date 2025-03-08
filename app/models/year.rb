class Year < ApplicationRecord
  belongs_to :first_trimester, class_name: 'Trimester'
  belongs_to :second_trimester, class_name: 'Trimester'
  belongs_to :third_trimester, class_name: 'Trimester'
  belongs_to :fourth_trimester, class_name: 'Trimester'

  accepts_nested_attributes_for :first_trimester, :second_trimester, :third_trimester, :fourth_trimester

  validate :validate_trimester_dates

  # Add default scope to exclude soft deleted records
  default_scope { where(isDeleted: false) }
  
  # Add scope to include soft deleted records when needed
  scope :with_deleted, -> { unscoped }

  # Soft delete method
  def soft_delete
    update!(isDeleted: true)
  end

  private

  def validate_trimester_dates
    trimesters = [first_trimester, second_trimester, third_trimester, fourth_trimester]
    
    trimesters.each_cons(2) do |prev_trimester, next_trimester|
      if prev_trimester.end_date >= next_trimester.start_date
        errors.add(:base, "Trimester dates must be sequential and not overlap")
      end
    end
  end
end
