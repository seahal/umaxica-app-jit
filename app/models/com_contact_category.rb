# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_categories
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default(""), not null
#  position    :integer          default(0), not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_com_contact_categories_on_parent_id  (parent_id)
#

class ComContactCategory < GuestsRecord
  include UppercaseId

  validates :description, length: { maximum: 255 }
  validates :parent_id, length: { maximum: 255 }

  has_many :com_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           inverse_of: :com_contact_category,
           dependent: :nullify
end
