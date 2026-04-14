# typed: false
# frozen_string_literal: true

# Deployment scope: Global
# Shared worldwide. A single database instance serves all regions (jp, us, etc.).
class SettingRecord < ApplicationRecord
  self.abstract_class = true

  connects_to database: { writing: :setting, reading: :setting_replica }
end
