# typed: false
# frozen_string_literal: true

# == Schema Information
#
# Table name: customer_preference_language_options
# Database name: guest
#
#  id :bigint           not null, primary key
#
class CustomerPreferenceLanguageOption < GuestRecord
  NOTHING = 0
  JA = 1
  EN = 2

  has_many :customer_preference_languages,
           class_name: "CustomerPreferenceLanguage",
           foreign_key: :option_id,
           inverse_of: :option,
           dependent: :restrict_with_error

  def name
    case id
    when JA then "ja"
    when EN then "en"
    end
  end

  DEFAULTS = [NOTHING, JA, EN].freeze

  def self.default_ids
    DEFAULTS
  end

  def self.ensure_defaults!
    ids = default_ids
    return if ids.blank?

    existing_ids = where(id: ids).pluck(:id)
    missing_ids = ids - existing_ids
    return if missing_ids.empty?

    missing_ids.each { |id| create!(id: id) }
  end

  self.primary_key = :id
end
