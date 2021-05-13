# frozen_string_literal: true

class Pet < ApplicationRecord
  # Validations
  validates :name, presence: true, length: {in: 1..100}
  validates :tag, length: {in: 0..100}, allow_nil: true, allow_blank: true
end
