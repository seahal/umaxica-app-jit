# frozen_string_literal: true

class CreateScavengerGlobalStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table :scavenger_global_statuses, id: :bigserial
  end
end
