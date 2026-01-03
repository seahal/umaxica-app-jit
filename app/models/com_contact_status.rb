# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_statuses
#
#  id          :string(255)      not null, primary key
#

class ComContactStatus < GuestRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }

  has_many :com_contacts,
           foreign_key: :status_id,
           inverse_of: :com_contact_status,
           dependent: :nullify

  validates :id, format: { with: /\A[A-Z0-9_]+\z/ }
end
