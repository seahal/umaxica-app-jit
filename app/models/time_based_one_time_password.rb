class TimeBasedOneTimePassword < AccountsRecord
  attr_accessor :first_token, :second_token
  encrypts :private_key

  #
  validates :private_key, presence: true
  validates :first_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
  validates :second_token, presence: true, length: { is: 6 }, numericality: { only_integer: true }
end
