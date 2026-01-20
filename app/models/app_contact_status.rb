# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_statuses
#
#  id           :string(255)      not null, primary key
#  active       :boolean          default(TRUE), not null
#  description  :string(255)      default(""), not null
#

class AppContactStatus < GuestRecord
  include StringPrimaryKey

  has_many :app_contacts,
           foreign_key: :status_id,
           inverse_of: :app_contact_status,
           dependent: :restrict_with_exception
  validates :id, uniqueness: { case_sensitive: false }

  validates :description, length: { maximum: 255 }
end
