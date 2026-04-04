# frozen_string_literal: true

class InsertCustomerPasskeyStatusesData < ActiveRecord::Migration[8.2]
  def up
    return if table_exists?(:customer_passkey_statuses) && CustomerPasskeyStatus.exists?(id: CustomerPasskeyStatus::ACTIVE)

    [
      { id: CustomerPasskeyStatus::ACTIVE },
      { id: CustomerPasskeyStatus::DISABLED },
      { id: CustomerPasskeyStatus::REVOKED },
      { id: CustomerPasskeyStatus::DELETED },
      { id: CustomerPasskeyStatus::NOTHING }
    ].each do |attrs|
      CustomerPasskeyStatus.find_or_initialize_by(id: attrs[:id]).update!(attrs)
    end
  end

  def down
    return unless table_exists?(:customer_passkey_statuses)

    CustomerPasskeyStatus.where(
      id: [
        CustomerPasskeyStatus::ACTIVE,
        CustomerPasskeyStatus::DISABLED,
        CustomerPasskeyStatus::REVOKED,
        CustomerPasskeyStatus::DELETED,
        CustomerPasskeyStatus::NOTHING
      ]
    ).destroy_all
  end
end
