class TimeBasedOneTimePassword < UniversalRecord
  #
  attr_accessor :first_token, :second_token

  # Encrypts the column value
  encrypts :private_key, downcase: true

  #
  validates :first_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
  validates :second_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
end
