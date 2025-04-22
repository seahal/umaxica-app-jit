# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :app do
      get "authentication/new"
      get "authentication/delete"
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
