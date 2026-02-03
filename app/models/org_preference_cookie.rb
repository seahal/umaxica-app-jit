# == Schema Information
#
# Table name: org_preference_cookies
# Database name: preference
#
#  id            :bigint           not null, primary key
#  functional    :boolean          default(FALSE), not null
#  performant    :boolean          default(FALSE), not null
#  targetable    :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  preference_id :bigint           not null
#
# Indexes
#
#  index_org_preference_cookies_on_preference_id  (preference_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (preference_id => org_preferences.id)
#

# frozen_string_literal: true

class OrgPreferenceCookie < PreferenceRecord
  belongs_to :preference, class_name: "OrgPreference", inverse_of: :org_preference_cookie

  validates :preference_id, uniqueness: true

  after_initialize :set_defaults

  validates :targetable, inclusion: { in: [true, false] }
  validates :performant, inclusion: { in: [true, false] }
  validates :functional, inclusion: { in: [true, false] }

  attr_accessor :consented

  alias_method :consented?, :consented
  # validates :consented, inclusion: { in: [true, false] }

  private

  def set_defaults
    return unless new_record?

    self.targetable = false if targetable.nil?
    self.performant = false if performant.nil?
    self.functional = false if functional.nil?
    #  self.consented = false if consented.nil?
  end
end
