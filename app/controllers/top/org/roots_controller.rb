module Top
  module Org
    class RootsController < ApplicationController
      def index
        redirect_to "https://#{ENV['EDGE_STAFF_URL']}", allow_other_host: true
      end
    end
  end
end
