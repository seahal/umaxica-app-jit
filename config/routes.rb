# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :docs do
    namespace :org do
      get "privacies/show"
    end
    namespace :com do
      get "privacies/show"
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
