# typed: strict
# frozen_string_literal: true

module Post::Org::Edge::V0
  class TimelinesController < ApplicationController
    def index
      @records = OrgTimeline.limit(50)
      render json: @records.as_json(only: %i(id slug_id published_at expires_at))
    end

    def show
      @record = OrgTimeline.find(params[:id])
      render json: @record.as_json(include: :latest_version_record)
    end
  end
end
