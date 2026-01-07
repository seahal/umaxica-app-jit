# frozen_string_literal: true

class CreateComPreferenceTimezoneOptions < ActiveRecord::Migration[8.2]
  def change
    create_table :com_preference_timezone_options, id: :uuid do |t|
    end
  end
end
