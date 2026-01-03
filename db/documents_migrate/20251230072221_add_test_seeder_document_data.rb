# frozen_string_literal: true

class AddTestSeederDocumentData < ActiveRecord::Migration[8.2]
  disable_ddl_transaction!
  STATUS_IDS = %w(NEYO ACTIVE DRAFT ARCHIVED).freeze

  def up
    # No-op: data seeding moved to fixtures.
  end

  def down
    # No-op: data seeding moved to fixtures.
  end
end
