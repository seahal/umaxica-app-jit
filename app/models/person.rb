class Person < IdentityRecord
  belongs_to :personality, polymorphic: true
end
