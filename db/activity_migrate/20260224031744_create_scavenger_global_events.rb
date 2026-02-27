# frozen_string_literal: true

class CreateScavengerGlobalEvents < ActiveRecord::Migration[8.2]
  def change
    create_table :scavenger_global_events, id: :bigserial
  end
end
