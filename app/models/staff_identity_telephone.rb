# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_telephones
#
#  id         :uuid             not null, primary key
#  number     :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#  staff_identity_telephone_status_id :string
#
# Indexes
#
#  index_staff_identity_telephones_on_staff_id  (staff_id)
#  index_staff_identity_telephones_on_staff_identity_telephone_status_id  (staff_identity_telephone_status_id)
#
class StaffIdentityTelephone < IdentitiesRecord
  include Telephone
  include SetId

  belongs_to :staff_identity_telephone_status, optional: true
  belongs_to :staff, optional: true
end
