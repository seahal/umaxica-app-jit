# == Schema Information
#
# Table name: org_preference_colortheme_options
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class OrgPreferenceColorthemeOption < PreferenceRecord
  include StringPrimaryKey

  has_many :org_preference_colorthemes,
           class_name: "OrgPreferenceColortheme",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Za-z0-9_]+\z/ }
end
