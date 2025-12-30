# frozen_string_literal: true

# == Schema Information
#
# Table name: post_statuses
#
#  id         :string           not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class PostStatus < IdentitiesRecord
  include StringPrimaryKey

  has_many :posts, dependent: :restrict_with_error
end
