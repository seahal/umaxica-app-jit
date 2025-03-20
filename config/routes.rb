# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :org do
      get "roots/index"
    end
    namespace :com do
      get "roots/index"
    end
    namespace :app do
      get "roots/index"
    end
  end
  # Pages for dev pages.
  draw :dev  unless Rails.env.production?
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
end
