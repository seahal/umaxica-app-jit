# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_telephones
# Database name: guest
#
#  id               :bigint           not null, primary key
#  telephone_number :string(1000)     default(""), not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  app_contact_id   :bigint           default(0), not null
#
# Indexes
#
#  index_app_contact_telephones_on_app_contact_id    (app_contact_id)
#  index_app_contact_telephones_on_telephone_number  (telephone_number)
#
# Foreign Keys
#
#  fk_rails_...  (app_contact_id => app_contacts.id)
#
class AppContactTelephone < GuestRecord
  include TelephoneNormalization

  belongs_to :app_contact, inverse_of: :app_contact_telephones

  normalize_telephone_field :telephone_number

  encrypts :telephone_number, deterministic: true
end
