# frozen_string_literal: true

module Top
  module App
    module Configuration
      class EmailsController < ApplicationController
        def new
          # New email configuration form
        end

        def edit
          # Edit email configuration form
        end
        def create
          # Create email configuration
          head :ok
        end


        def update
          # Update email configuration
          head :ok
        end
      end
    end
  end
end
