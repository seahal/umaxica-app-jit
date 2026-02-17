# frozen_string_literal: true

RUNTIME_FILE_CACHE = ActiveSupport::Cache::FileStore.new(
  Rails.root.join("tmp/runtime_cache"),
  namespace: "runtime",
)
