# frozen_string_literal: true

# ToDo: Use table partitioning.

class CreateStaffs < ActiveRecord::Migration[7.2]
  def change
    # FIXME: need hashed partition.
    create_table :staffs, id: :binary do |t|
      t.string :otp_private_key
      t.timestamps
    end
  end
end
