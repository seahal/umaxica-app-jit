# frozen_string_literal: true

Rails.application.routes.draw do
  # apex page
  draw :apex
  #
  draw :www
  # api endpoint url
  draw :api
  # endpoint for sign
  draw :sign
  # endpoint for docs
  draw :docs
  # endpoint for news
  draw :news
  # endpoint for help
  draw :help
end
