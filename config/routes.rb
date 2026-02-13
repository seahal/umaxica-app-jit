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

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'
end
