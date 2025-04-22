# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :docs do
    namespace :org do
      get "terms/index"
    end
    namespace :com do
      get "terms/index"
    end
    namespace :app do
      get "terms/index"
    end
  end
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
  #
  draw :news
  #
  draw :docs
end
