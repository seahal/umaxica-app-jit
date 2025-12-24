# == Schema Information
#
# Table name: com_contact_statuses
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default("00000000-0000-0000-0000-000000000000"), not null
#  position    :integer          default(0), not null
#
# Indexes
#
#  index_com_contact_statuses_on_parent_id  (parent_id)
#

class ComContactStatus < GuestsRecord
  include UppercaseId

  has_many :com_contacts,
           foreign_key: :contact_status_id,
           inverse_of: :com_contact_status,
           dependent: :nullify
end
