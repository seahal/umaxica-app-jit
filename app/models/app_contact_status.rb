# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_statuses
#
#  id           :string(255)      not null, primary key
#  active       :boolean          default(TRUE), not null
#  description  :string(255)      default(""), not null
#

class AppContactStatus < GuestsRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }

  has_many :app_contacts,
           foreign_key: :status_id,
           inverse_of: :app_contact_status,
           dependent: :nullify
end
