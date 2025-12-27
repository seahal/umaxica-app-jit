# frozen_string_literal: true

class TimelineVersionWriter
  def self.write!(timeline, attrs:, editor: nil)
    version_class, timeline_key =
      case timeline
      when AppTimeline then [AppTimelineVersion, :app_timeline]
      when ComTimeline then [ComTimelineVersion, :com_timeline]
      when OrgTimeline then [OrgTimelineVersion, :org_timeline]
      else
        raise ArgumentError, "unsupported timeline type: #{timeline.class}"
      end

    version_class.create!(
      timeline_key => timeline,
      :permalink => timeline.permalink,
      :response_mode => timeline.response_mode,
      :redirect_url => timeline.redirect_url,
      :published_at => timeline.published_at,
      :expires_at => timeline.expires_at,
      :title => attrs[:title],
      :description => attrs[:description],
      :body => attrs[:body],
      :edited_by_type => editor&.class&.name,
      :edited_by_id => editor&.id,
    )
  end
end
