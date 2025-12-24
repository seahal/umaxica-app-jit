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

  has_many :app_contacts,
           foreign_key: :contact_category_title,
           primary_key: :id,
           dependent: :nullify,
           inverse_of: :app_contact_category
end
