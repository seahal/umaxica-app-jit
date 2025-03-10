# frozen_string_literal: true

module Www
  module Com
    class TermsController < ApplicationController
      def show
        render plain: gen_original_uuid
      end
    end
  end
end
