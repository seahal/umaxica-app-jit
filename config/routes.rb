# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :org do
      get "registrations/new"
    end
    namespace :app do
      get "registrations/new"
    end
  end
  # Pages for dev pages.
  draw :dev  unless Rails.env.production?
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
end
