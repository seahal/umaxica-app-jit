# == Schema Information
#
# Table name: app_preference_colortheme_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class AppPreferenceColorthemeOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  LIGHT = 1
  DARK = 2
  SYSTEM = 3

  has_many :app_preference_colorthemes,
           class_name: "AppPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:id) }

  def name
    case id
    when LIGHT then "light"
    when DARK then "dark"
    when SYSTEM then "system"
    end
  end

  def self.ensure_defaults!
    ids = [LIGHT, DARK, SYSTEM]
    existing = where(id: ids).pluck(:id)
    (ids - existing).each { |id| create!(id: id) }
  end
end
