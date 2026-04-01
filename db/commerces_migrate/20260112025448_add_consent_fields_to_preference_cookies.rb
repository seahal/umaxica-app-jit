# frozen_string_literal: true

class AddConsentFieldsToPreferenceCookies < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!

  def change
    add_column(:app_preference_cookies, :consented, :boolean, null: false, default: false)
    add_column(:app_preference_cookies, :consented_at, :datetime)
    add_reference(
      :app_preference_cookies,
      :consent_version,
      type: :bigint,
      index: { algorithm: :concurrently },
    )

    add_column(:org_preference_cookies, :consented, :boolean, null: false, default: false)
    add_column(:org_preference_cookies, :consented_at, :datetime)
    add_reference(
      :org_preference_cookies,
      :consent_version,
      type: :bigint,
      index: { algorithm: :concurrently },
    )

    add_column(:com_preference_cookies, :consented, :boolean, null: false, default: false)
    add_column(:com_preference_cookies, :consented_at, :datetime)
    add_reference(
      :com_preference_cookies,
      :consent_version,
      type: :bigint,
      index: { algorithm: :concurrently },
    )
  end
end
