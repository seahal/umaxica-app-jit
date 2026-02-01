# == Schema Information
#
# Table name: org_preference_colortheme_options
# Database name: preference
#
#  id         :integer          not null, primary key
#  position   :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  org_preference_colortheme_options_position_unique  (position) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceColorthemeOption < PreferenceRecord
  include CodeIdentifiable

  has_many :org_preference_colorthemes,
           class_name: "OrgPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error
  scope :ordered, -> { order(:position, :id) }
                 format: { with: /\A[A-Za-z0-9_]+\z/ }

  validates :position,
            presence: true,
            numericality: { only_integer: true, greater_than: 0 },
            uniqueness: true
end
