# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :app do
      namespace :setting do
        get "recoveries/index"
        get "recoveries/new"
        get "recoveries/show"
        get "recoveries/edit"
      end
    end
  end
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
end
