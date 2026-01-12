# == Schema Information
#
# Table name: app_preference_cookies
#
#  id                 :uuid             not null, primary key
#  preference_id      :uuid             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  targetable         :boolean          default(FALSE), not null
#  performant         :boolean          default(FALSE), not null
#  functional         :boolean          default(FALSE), not null
#  consented          :boolean          default(FALSE), not null
#  consented_at       :datetime
#  consent_version_id :uuid
#
# Indexes
#
#  index_app_preference_cookies_on_consent_version_id  (consent_version_id)
#  index_app_preference_cookies_on_preference_id       (preference_id) UNIQUE
#

# frozen_string_literal: true

class AppPreferenceCookie < PreferenceRecord
  belongs_to :preference,
             class_name: "AppPreference",
             inverse_of: :app_preference_cookie

  after_initialize :set_defaults

  validates :preference_id, uniqueness: true
  validates :targetable, inclusion: { in: [true, false] }
  validates :performant, inclusion: { in: [true, false] }
  validates :functional, inclusion: { in: [true, false] }
  validates :consented, inclusion: { in: [true, false] }

  private

  def set_defaults
    return unless new_record?

    self.targetable = false if targetable.nil?
    self.performant = false if performant.nil?
    self.functional = false if functional.nil?
    self.consented = false if consented.nil?
  end
end
