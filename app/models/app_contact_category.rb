# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
#
#  id          :string(255)      not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class AppContactCategory < GuestsRecord
  include UppercaseId

  has_many :app_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           dependent: :restrict_with_error,
           inverse_of: :app_contact_category

  validates :description, length: { maximum: 255 }
end
