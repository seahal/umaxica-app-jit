# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_categories
#
#  id          :string(255)      not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class ComContactCategory < GuestRecord
  include UppercaseId

  has_many :com_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           inverse_of: :com_contact_category,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
