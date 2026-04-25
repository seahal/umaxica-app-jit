# typed: strict
# frozen_string_literal: true

module Jit::Distributor::Post::Org::Edge::V0::Timelines
  class VersionsController < ApplicationController
    def index
      @record = OrgTimeline.find(params[:timeline_id])
      @versions = @record.org_timeline_versions
      render json: @versions
    end

    def show
      @version = OrgTimelineVersion.find(params[:id])
      render json: @version
    end
  end
end
