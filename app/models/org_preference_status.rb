# == Schema Information
#
# Table name: org_preference_statuses
#
#  id         :string(255)      default("NEYO"), not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

# frozen_string_literal: true

class OrgPreferenceStatus < PreferenceRecord
  include StringPrimaryKey

  has_many :org_preferences,
           class_name: "OrgPreference",
           foreign_key: "status_id",
           primary_key: "id",
           inverse_of: :org_preference_status,
           dependent: :restrict_with_error

  before_validation { self.id = id&.upcase }
  validates :id, presence: true, length: { maximum: 255 }, uniqueness: { case_sensitive: false },
                 format: { with: /\A[A-Z0-9_]+\z/ }
end
