# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_identity_emails
#
#  id         :uuid             not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  staff_id   :bigint
#
# Indexes
#
#  index_staff_identity_emails_on_staff_id  (staff_id)
#
class StaffIdentityEmail < IdentitiesRecord
  include SetId
  include Email
end
