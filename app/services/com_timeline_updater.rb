# frozen_string_literal: true

class ComTimelineUpdater
  def self.call(timeline:, attrs:, editor: nil)
    NewsRecord.transaction do
      timeline.update!(timeline_attributes(attrs))
      TimelineVersionWriter.write!(timeline, attrs: attrs, editor: editor)
    end
  end

  def self.timeline_attributes(attrs)
    attrs.slice(:response_mode, :redirect_url, :published_at, :expires_at, :position)
  end
  private_class_method :timeline_attributes
end
