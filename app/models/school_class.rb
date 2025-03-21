class SchoolClass < ApplicationRecord
  belongs_to :teacher, class_name: 'Teacher'
  belongs_to :year
  has_and_belongs_to_many :students, join_table: 'school_classes_students'
  
  validates :name, presence: true
  validates :grade, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :year, presence: true
  
  validate :ensure_teacher_type
  
  scope :with_deleted, -> { unscope(where: :isDeleted) }
  
  def soft_delete
    Rails.logger.info "Attempting to soft delete SchoolClass #{id}"
    result = update(isDeleted: true)
    Rails.logger.info "Soft delete result: #{result}, isDeleted=#{reload.isDeleted}"
    result
  end
  
  def self.default_scope
    where(isDeleted: false)
  end
  
  private def ensure_teacher_type
    if teacher.present? && !teacher.is_a?(Teacher)
      errors.add(:teacher, "must be a Teacher, not a #{teacher.type}")
    end
  end
end
