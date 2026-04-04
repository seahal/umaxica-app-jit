# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_telephones
# Database name: guest
#
#  id               :bigint           not null, primary key
#  hotp_counter     :integer
#  hotp_secret      :string
#  telephone_number :string(1000)     default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  com_contact_id   :bigint           default(0), not null
#
# Indexes
#
#  index_com_contact_telephones_on_com_contact_id_unique  (com_contact_id) UNIQUE
#  index_com_contact_telephones_on_telephone_number       (telephone_number)
#
# Foreign Keys
#
#  fk_rails_...  (com_contact_id => com_contacts.id)
#

class ComContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :com_contact, inverse_of: :com_contact_telephone

  # E.164 normalization and validation
  normalize_telephone_field :telephone_number

  validates :com_contact_id, uniqueness: true

  encrypts :telephone_number, deterministic: true
end
