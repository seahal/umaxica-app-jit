# frozen_string_literal: true

Rails.application.routes.draw do
  # Pages for org pages.
  draw :dev unless Rails.env.production?
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
  #
  draw :news
  #
  draw :docs
end
