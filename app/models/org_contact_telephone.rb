# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: org_contact_telephones
# Database name: guest
#
#  id               :bigint           not null, primary key
#  telephone_number :string(1000)     default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  org_contact_id   :bigint           default(0), not null
#
# Indexes
#
#  index_org_contact_telephones_on_org_contact_id    (org_contact_id)
#  index_org_contact_telephones_on_telephone_number  (telephone_number)
#
# Foreign Keys
#
#  fk_rails_...  (org_contact_id => org_contacts.id)
#

class OrgContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :org_contact, inverse_of: :org_contact_telephones

  # E.164 normalization and validation
  normalize_telephone_field :telephone_number

  encrypts :telephone_number, deterministic: true
end
