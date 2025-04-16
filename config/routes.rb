# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :org do
      get "cookies/show"
      get "cookies/edit"
      get "cookies/update"
    end
    namespace :com do
      get "cookies/show"
      get "cookies/edit"
      get "cookies/update"
    end
    namespace :app do
      get "cookies/show"
      get "cookies/edit"
      get "cookies/update"
    end
  end
  # Pages for org pages.
  draw :dev unless Rails.env.production?
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
end
