# typed: false
# frozen_string_literal: true

class Acme::Org::Emergency::Com::TokensController < ApplicationController
  def show
  end

  def update
    redirect_to(action: :show)
  end
end
