# == Schema Information
#
# Table name: com_preference_colortheme_options
# Database name: preference
#
#  id   :bigint           not null, primary key
#  code :citext           not null
#
# Indexes
#
#  index_com_preference_colortheme_options_on_code  (code) UNIQUE
#

# frozen_string_literal: true

class ComPreferenceColorthemeOption < PreferenceRecord
  include CodeIdentifiable

  has_many :com_preference_colorthemes,
           class_name: "ComPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
end
