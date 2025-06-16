# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check endpoints
  get 'health', to: 'health#index'
  get 'health/kafka', to: 'health#kafka'
  
  namespace :news do
    namespace :app do
      get "healths/show"
    end
  end
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
  # endpoint for news
  draw :news
  # endpoint for docs
  draw :docs
end
