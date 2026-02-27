# typed: false
# frozen_string_literal: true

class Apex::App::Emergency::App::TokensController < ApplicationController
  def show
  end

  def update
    redirect_to action: :show
  end
end
