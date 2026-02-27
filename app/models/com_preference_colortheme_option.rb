# typed: false
# == Schema Information
#
# Table name: com_preference_colortheme_options
# Database name: preference
#
#  id :bigint           not null, primary key
#

# frozen_string_literal: true

class ComPreferenceColorthemeOption < PreferenceRecord
  # Fixed IDs - do not modify these values
  LIGHT = 1
  DARK = 2
  SYSTEM = 3

  has_many :com_preference_colorthemes,
           class_name: "ComPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(primary_key) }

  def name
    case id
    when LIGHT then "light"
    when DARK then "dark"
    when SYSTEM then "system"
    end
  end
end
