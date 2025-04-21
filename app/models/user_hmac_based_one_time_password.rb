class UserHmacBasedOneTimePassword < AccountsRecord
  belongs_to :user
  belongs_to :hmac_based_one_time_password
end
