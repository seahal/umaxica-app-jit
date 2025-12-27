# frozen_string_literal: true

class AddMissingIndexesToUniversals < ActiveRecord::Migration[8.2]
  def change
    # Add indexes for status_id on all occurrence tables
    %w(
      area
      domain
      email
      ip
      staff
      telephone
      user
      zip
    ).each do |prefix|
      add_index :"#{prefix}_occurrences", :status_id
    end
  end
end
