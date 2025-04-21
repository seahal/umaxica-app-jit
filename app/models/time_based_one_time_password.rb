class TimeBasedOneTimePassword < AccountsRecord
  encrypts :private_key
end
