module Auth
  module App
    module V1
      class CsrfController < ApplicationController
        include ::Csrf
      end
    end
  end
end
