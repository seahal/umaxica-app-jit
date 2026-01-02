# frozen_string_literal: true

class AddClientIdToAvatars < ActiveRecord::Migration[8.2]
  def change
    safety_assured do
      add_reference :avatars,
                    :client,
                    foreign_key: { to_table: :clients, validate: false },
                    type: :uuid
    end
  end
end
