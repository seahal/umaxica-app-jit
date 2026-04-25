# typed: strict
# frozen_string_literal: true

module Post::Com::Edge::V0::Timelines
  class VersionsController < ApplicationController
    def index
      @record = ComTimeline.find(params[:timeline_id])
      @versions = @record.com_timeline_versions
      render json: @versions
    end

    def show
      @version = ComTimelineVersion.find(params[:id])
      render json: @version
    end
  end
end
