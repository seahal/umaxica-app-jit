# frozen_string_literal: true

class AddMissingIndexesToUniversals < ActiveRecord::Migration[8.2]
  def change
    %i[
      area
      domain
      email
      ip
      staff
      telephone
      user
      zip
    ].each do |prefix|
      safety_assured { add_index(:"#{prefix}_occurrences", :status_id) }
    end
  end
end
