# typed: false
# frozen_string_literal: true

class AddAuthContextToAuthorizationCodes < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      change_table :authorization_codes, bulk: true do |t|
        t.string :auth_method, null: false, default: ""
        t.string :acr, null: false, default: "aal1"
      end
    end
  end
end
