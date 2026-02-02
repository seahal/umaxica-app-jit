# frozen_string_literal: true

# == Schema Information
#
# Table name: com_contact_categories
# Database name: guest
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_contact_categories_on_code  (code) UNIQUE
#

class ComContactCategory < GuestRecord
  include CodeIdentifiable

  has_many :com_contacts,
           foreign_key: :category_id,
           primary_key: :id,
           inverse_of: :com_contact_category,
           dependent: :restrict_with_error

  validates :description, length: { maximum: 255 }
end
