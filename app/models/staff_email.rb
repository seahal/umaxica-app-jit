# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_emails
#
#  id         :binary           not null, primary key
#  address    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  uuid_id    :uuid             not null
#
class StaffEmail < IdentifiersRecord
  include SetId
  include Email
end
