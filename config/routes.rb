# frozen_string_literal: true

Rails.application.routes.draw do
  draw :apex
  # sign in / up
  draw :sign
  # regional
  ## back end of edge endpoints
  draw :core
  # endpoints for help
  draw :help
  # endpoints for docs
  draw :docs
  # endpoints for news
  draw :news

  resources :posts, only: [:index]

  # Test routes (only in test environment)
  if Rails.env.test?
    namespace :auth do
      get "policy_test/public_strict_action", to: "policy_test#public_strict_action"
      get "policy_test/auth_required_action", to: "policy_test#auth_required_action"
      get "policy_test/auth_required_json_action", to: "policy_test#auth_required_json_action"
      get "policy_test/guest_only_action", to: "policy_test#guest_only_action"
      get "policy_test/guest_only_json_action", to: "policy_test#guest_only_json_action"
    end

    namespace :test do
      resource :surface, only: :show
    end
  end
end
