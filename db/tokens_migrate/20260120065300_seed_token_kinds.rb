# frozen_string_literal: true

class SeedTokenKinds < ActiveRecord::Migration[8.2]
  TOKEN_KINDS = %w(BROWSER_WEB CLIENT_IOS CLIENT_ANDROID).freeze

  def up
    TOKEN_KINDS.each do |kind_id|
      UserTokenKind.find_or_create_by!(id: kind_id)
      StaffTokenKind.find_or_create_by!(id: kind_id)
    end
  end

  def down
    # Seeds are typically not rolled back, but provide for consistency
    UserTokenKind.where(id: TOKEN_KINDS).delete_all
    StaffTokenKind.where(id: TOKEN_KINDS).delete_all
  end
end
