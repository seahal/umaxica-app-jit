require "test_helper"


class AvatarUploaderTest < ActiveSupport::TestCase
  DummyModel = Struct.new(:id) do
    def self.to_s
      "DummyModel"
    end
  end

  def setup
    @model = DummyModel.new(42)
    @uploader = AvatarUploader.new(@model, :avatar)
  end

  def test_store_dir
    expected = "uploads/dummy_model/avatar/42"

    assert_equal expected, @uploader.store_dir
  end

  # rubocop:disable Minitest/MultipleAssertions
  def test_extension_allowlist
    allowlist = @uploader.extension_allowlist

    assert_includes allowlist, "png"
    assert_includes allowlist, "jpg"
    assert_includes allowlist, "jpeg"
    assert_includes allowlist, "gif"
  end
  # rubocop:enable Minitest/MultipleAssertions

  def test_filename_default
    assert_equal "something.jpg", @uploader.filename
  end
end

