# frozen_string_literal: true

Rails.application.routes.draw do
  # global
  # top level pages
  # TODO: RENAME => apex
  draw :apex
  # sign in / up
  draw :sign
  # regional
  ## top endpoint
  # TODO: RENAME => back
  draw :back
  # endpoint for docs
  draw :docs
  # endpoint for news
  draw :news
  # endpoint for help
  draw :help

  # mount Rswag::Ui::Engine => '/api-docs'
  # mount Rswag::Api::Engine => '/api-docs'
end
