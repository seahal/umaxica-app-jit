# NOTE: This code is used to precompile assets outside the production environment.

require_relative "./production"

Rails.application.configure do
  config.require_master_key = false
  config.assets.compile = true
  config.assets.digest = true
end
