# frozen_string_literal: true

Rails.application.routes.draw do
  # global
  # top level pages
  # TODO: RENAME to root
  draw :peak
  # sign in / up
  draw :auth
  # regional
  ## back end of edge endpoints
  draw :core
  # endpoints for help
  draw :help
  # endpoints for docs
  draw :docs
  # endpoints for news
  draw :news

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'
end
