# typed: false
# frozen_string_literal: true

class Apex::Org::Emergency::App::CachesController < ApplicationController
  def show
    head :ok
  end

  def update
    head :no_content
  end

  def destroy
    head :no_content
  end
end
