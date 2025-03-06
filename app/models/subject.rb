class Subject < ApplicationRecord
  has_and_belongs_to_many :teachers, join_table: 'subjects_teachers'

  validates :name, presence: true, uniqueness: true

  default_scope { where(isDeleted: false) }
  scope :with_deleted, -> { unscope(where: :isDeleted) }

  def soft_delete
    update_column(:isDeleted, true)
  end
end
