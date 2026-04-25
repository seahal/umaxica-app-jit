# typed: strict
# frozen_string_literal: true

module Post::Dev
  class RobotsController < ActionController::API
    def show
      render plain: "User-agent: *\nDisallow: /\n"
    end
  end
end
