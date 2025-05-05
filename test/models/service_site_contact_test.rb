# == Schema Information
#
# Table name: service_site_contacts
#
#  id               :bigint           not null, primary key
#  description      :text
#  email_address    :string
#  telephone_number :string
#  title            :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
require "test_helper"

class ServiceSiteContactTest < ActiveSupport::TestCase
  test "the truth" do
    assert true
  end
end
