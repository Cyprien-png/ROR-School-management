class Person < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # STI subclasses
  def self.types
    %w[Teacher Student Dean]
  end

  def self.inherited(child)
    child.include Devise::Models::DatabaseAuthenticatable
    super
  end
end
