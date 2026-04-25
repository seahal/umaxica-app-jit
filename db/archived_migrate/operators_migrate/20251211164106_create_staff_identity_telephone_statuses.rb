# frozen_string_literal: true

class CreateStaffIdentityTelephoneStatuses < ActiveRecord::Migration[8.2]
  def up
    create_table(:staff_identity_telephone_statuses, id: :string, limit: 255)

    safety_assured do
      execute("ALTER TABLE staff_identity_telephone_statuses ALTER COLUMN id SET DEFAULT 'UNVERIFIED'")
    end
  end

  def down
    drop_table(:staff_identity_telephone_statuses)
  end
end
