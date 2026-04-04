# frozen_string_literal: true

class CreateCustomerPasskeyStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table(:customer_passkey_statuses, if_not_exists: true) do |t|
      t.timestamps
    end
  end
end
