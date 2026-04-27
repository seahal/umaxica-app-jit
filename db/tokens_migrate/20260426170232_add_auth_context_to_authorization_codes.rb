# typed: false
# frozen_string_literal: true

class AddAuthContextToAuthorizationCodes < ActiveRecord::Migration[8.2]
  def change
    add_column(:authorization_codes, :auth_method, :string)
    add_column(:authorization_codes, :acr, :string)
  end
end
