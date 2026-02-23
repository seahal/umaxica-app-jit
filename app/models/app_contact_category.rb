# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: app_contact_categories
# Database name: guest
#
#  id :bigint           not null, primary key
#
class AppContactCategory < GuestRecord
  NEYO = 1
  APPLICATION_INQUIRY = 2

  has_many :app_contacts,
           foreign_key: :category_id,
           inverse_of: :app_contact_category,
           dependent: :restrict_with_exception
end
