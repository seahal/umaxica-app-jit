# == Schema Information
#
# Table name: org_preference_cookies
#
#  id            :uuid             not null, primary key
#  preference_id :uuid             not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  targetable    :boolean          default(FALSE), not null
#  performant    :boolean          default(FALSE), not null
#  functional    :boolean          default(FALSE), not null
#
# Indexes
#
#  index_org_preference_cookies_on_preference_id  (preference_id) UNIQUE
#

# frozen_string_literal: true

class OrgPreferenceCookie < PreferenceRecord
  belongs_to :preference, class_name: "OrgPreference", inverse_of: :org_preference_cookie

  after_initialize :set_defaults

  validates :targetable, inclusion: { in: [true, false] }
  validates :performant, inclusion: { in: [true, false] }
  validates :functional, inclusion: { in: [true, false] }

  private

  def set_defaults
    return unless new_record?

    self.targetable = false if targetable.nil?
    self.performant = false if performant.nil?
    self.functional = false if functional.nil?
  end
end
