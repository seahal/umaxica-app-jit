# frozen_string_literal: true

Rails.application.routes.draw do
  # for pages which show html
  draw :www
  # api endpoint url
  draw :api
  #
  draw :news
  #
  draw :docs
end
