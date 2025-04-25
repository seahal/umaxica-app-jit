class TimeBasedOneTimePassword < UniversalRecord
  #
  # has_many :staff_time_based_one_time_passwords, dependent: :destroy
  # has_many :user_time_based_one_time_passwords, dependent: :destroy

  #
  attr_accessor :first_token, :second_token

  # Encrypts the column value
  encrypts :private_key, downcase: true

  #
  validates :private_key, presence: true
  validates :first_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
  validates :second_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
end
