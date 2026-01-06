# frozen_string_literal: true

class AddContextToUserAudits < ActiveRecord::Migration[8.2]
  def change
    add_column :user_audits, :context, :jsonb, default: {}, null: false
  end
end
