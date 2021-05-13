# frozen_string_literal: true

class Pet < ApplicationRecord
  # Validations
  validates :name, presence: true
  validate :validate_pet_id

  private

  def validate_pet_id
    errors.add(:id, 'pet already exists') if Pet.exists?(id)
  end
end
