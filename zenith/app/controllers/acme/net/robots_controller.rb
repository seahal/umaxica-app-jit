# typed: strict
# frozen_string_literal: true

module Acme::Net
  class RobotsController < ActionController::API
    def show
      render plain: "User-agent: *\nDisallow: /\n"
    end
  end
end
