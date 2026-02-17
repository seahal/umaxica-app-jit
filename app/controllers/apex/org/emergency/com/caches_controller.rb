# frozen_string_literal: true

class Apex::Org::Emergency::Com::CachesController < ApplicationController
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
