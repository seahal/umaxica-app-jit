# == Schema Information
#
# Table name: telephones
#
#  id                                 :binary           not null, primary key
#  number                             :string
#  created_at                         :datetime         not null
#  updated_at                         :datetime         not null
#  universal_telephone_identifiers_id :binary
#
class Telephone < AccountsRecord
  attr_accessor :confirm_policy, :confirm_fido2
  validates :confirm_policy, acceptance: true
  validates :confirm_fido2, acceptance: true
end
