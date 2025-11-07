module Bff
  module Org
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['BFF_STAFF_URL']}", allow_other_host: true
      end
    end
  end
end
