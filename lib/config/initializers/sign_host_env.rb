# typed: false
# frozen_string_literal: true

require Rails.root.join("lib/sign_host_env").to_s

SignHostEnv.validate! if Rails.env.production?
