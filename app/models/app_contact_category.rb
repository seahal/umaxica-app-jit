# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
# Database name: guest
#
#  id :string(255)      not null, primary key
#
# Indexes
#
#  index_app_contact_categories_on_lower_id  (lower((id)::text)) UNIQUE
#

class AppContactCategory < GuestRecord
  include CodeIdentifiable

  has_many :app_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           dependent: :restrict_with_error,
           inverse_of: :app_contact_category

  validates :description, length: { maximum: 255 }
end
