# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::App::Edge::V0::Timelines
  class VersionsController < ApplicationController
    def index
      @record = AppTimeline.find(params[:timeline_id])
      @versions = @record.app_timeline_versions
      render json: @versions
    end

    def show
      @version = AppTimelineVersion.find(params[:id])
      render json: @version
    end
  end
end
