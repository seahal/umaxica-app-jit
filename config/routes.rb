# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :sign do
    namespace :org do
      namespace :verification do
        get "passkey/new"
        get "passkey/create"
      end
      get "verification/show"
    end
    namespace :app do
      namespace :verification do
        get "emails/new"
        get "emails/create"
        get "emails/edit"
        get "emails/update"
        get "totp/new"
        get "totp/create"
        get "passkey/new"
        get "passkey/create"
      end
      get "verification/show"
    end
  end
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

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'
end
