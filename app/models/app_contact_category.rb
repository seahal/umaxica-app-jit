# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
#
#  id          :string(255)      not null, primary key
#  active      :boolean          default(TRUE), not null
#  created_at  :datetime         not null
#  description :string(255)      default(""), not null
#  parent_id   :string(255)      default("00000000-0000-0000-0000-000000000000"), not null
#  position    :integer          default(0), not null
#  updated_at  :datetime         not null
#
# Indexes
#
#  index_app_contact_categories_on_parent_id  (parent_id)
#

class AppContactCategory < GuestsRecord
  include UppercaseId

  NIL_UUID = "00000000-0000-0000-0000-000000000000"

  belongs_to :parent,
             class_name: "AppContactCategory",
             inverse_of: :children,
             optional: true

  has_many :children,
           class_name: "AppContactCategory",
           foreign_key: :parent_id,
           inverse_of: :parent,
           dependent: :restrict_with_error

  has_many :app_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           dependent: :nullify,
           inverse_of: :app_contact_category

  validates :description, length: { maximum: 255 }
  validates :parent_id, presence: true, length: { maximum: 255 }

  def root?
    parent_id == NIL_UUID
  end
end
