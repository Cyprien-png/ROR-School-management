class Person < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validate :prevent_direct_person_creation, on: :create

  default_scope { where(isDeleted: false) }
  scope :with_deleted, -> { unscope(where: :isDeleted) }

  # Soft delete method
  def soft_delete
    update_column(:isDeleted, true)
  end

  # STI subclasses
  def self.types
    %w[Teacher Student Dean]
  end

  def self.inherited(child)
    child.include Devise::Models::DatabaseAuthenticatable
    super
  end

  private

  def prevent_direct_person_creation
    if self.class == Person
      errors.add(:base, "Cannot create a generic person. Please create a student, teacher or dean specifically.")
    end
  end
end
