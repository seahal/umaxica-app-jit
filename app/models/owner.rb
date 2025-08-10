class Owner < ApplicationRecord
  validates :name, presence: true
end