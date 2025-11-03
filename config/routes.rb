# frozen_string_literal: true

Rails.application.routes.draw do
  # global 
  ## sing up/in page 
  draw :sign
  # regional
  ## www endpoint
  draw :www
  # api endpoint url
  draw :api
  # endpoint for docs
  draw :docs
  # endpoint for news
  draw :news
  # endpoint for help
  draw :help
end
