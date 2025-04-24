require "test_helper"

class DocumentTest < ActiveSupport::TestCase
  setup do
    Document.create(id: '01', parent_id: nil, prev_id: nil, succ_id: nil, title: 'TERM', description: '')
    Document.create(id: '10', parent_id: '01', prev_id: nil, succ_id: '11', title: '', description: '1')
    Document.create(id: '11', parent_id: '01', prev_id: '10', succ_id: nil, title: '', description: '2')
    Document.create(id: '00', parent_id: nil, prev_id: nil, succ_id: nil, title: 'PRIVACY', description: '')
  end

  test "the truth" do
    assert true
  end
end
