# frozen_string_literal: true

class EnforceExpiresAtOnUserIdentitySocials < ActiveRecord::Migration[8.2]
  def change
    safety_assured { change_column_null(:user_identity_social_apples, :expires_at, false) }
    safety_assured { change_column_null(:user_identity_social_googles, :expires_at, false) }

    safety_assured { add_index(:user_identity_social_apples, :expires_at) }
    safety_assured { add_index(:user_identity_social_googles, :expires_at) }
  end
end
