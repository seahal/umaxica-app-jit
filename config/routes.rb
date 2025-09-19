# frozen_string_literal: true

Rails.application.routes.draw do
  root to: "home#index"
  draw :apex # for apex page
  draw :api  # api endpoint url
  draw :auth # endpoint for auth
  draw :docs # endpoint for docs
  draw :news # endpoint for news
  draw :help # endpoint for help
end
