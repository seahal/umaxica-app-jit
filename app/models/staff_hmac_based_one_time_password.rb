class StaffHmacBasedOneTimePassword < AccountsRecord
  belongs_to :staff
  belongs_to :hmac_based_one_time_password
end
