# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: staff_messages
# Database name: message
#
#  id         :bigint           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  public_id  :string           default(""), not null
#  staff_id   :bigint           not null
#
# Indexes
#
#  index_staff_messages_on_public_id  (public_id) UNIQUE
#  index_staff_messages_on_staff_id   (staff_id)
#

class StaffMessage < MessageRecord
  include ::PublicId

  belongs_to :staff, optional: false, inverse_of: :staff_messages
  has_many :admin_messages, inverse_of: :staff_message, dependent: :delete_all
end
