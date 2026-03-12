# frozen_string_literal: true

class CreateJwtOccurrenceStatuses < ActiveRecord::Migration[8.2]
  def change
    create_table :jwt_occurrence_statuses do |t|
      t.string :name, null: false, default: ""
    end
  end
end
