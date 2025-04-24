# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :www do
    namespace :org do
      get "withdrawals/new"
      get "withdrawals/edit"
    end
    namespace :com do
      get "withdrawals/new"
      get "withdrawals/edit"
    end
    namespace :app do
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
