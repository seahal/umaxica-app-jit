# frozen_string_literal: true

Rails.application.routes.draw do
  # global
  # top level pages
  # TODO: RENAME => apex
  draw :peak
  # sign in / up
  draw :auth
  # regional
  ## top endpoint
  # TODO: RENAME => back
  draw :base
  # endpoint for docs
  draw :docs
  # endpoint for news
  draw :news
  # endpoint for help
  draw :help

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'
end
