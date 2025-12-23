module Core
  module Com
    module V1
      class CsrfController < ApplicationController
        include ::Csrf
      end
    end
  end
end
