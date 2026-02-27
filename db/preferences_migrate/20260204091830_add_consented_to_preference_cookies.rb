# frozen_string_literal: true

class AddConsentedToPreferenceCookies < ActiveRecord::Migration[8.2]
  def change
    %w(app com org).each do |prefix|
      add_column :"#{prefix}_preference_cookies", :consented, :boolean, null: false, default: false, if_not_exists: true
      add_column :"#{prefix}_preference_cookies", :consented_at, :datetime, if_not_exists: true
      add_column :"#{prefix}_preference_cookies", :consent_version, :uuid, if_not_exists: true
    end
  end
end
