require "test_helper"

class PersonTest < ActiveSupport::TestCase
  test "person can belong to staff" do
    staff = staffs(:one)
    person = staff.people.create!(body: "Staff member profile")

    assert_equal "Staff", person.personality_type
    assert_equal person.personality_id, staff.id
    assert_equal person.personality, staff
  end

  test "person can belong to user" do
    user = users(:one)
    person = user.people.create!(body: "User profile")

    assert_equal "User", person.personality_type
    assert_equal person.personality_id, user.id
    assert_equal person.personality, user
  end

  test "staff can have many people" do
    staff = staffs(:one)
    person1 = staff.people.create!(body: "First person")
    person2 = staff.people.create!(body: "Second person")

    assert_equal 2, staff.people.count
    assert_includes staff.people, person1
    assert_includes staff.people, person2
  end

  test "user can have many people" do
    user = users(:one)
    person1 = user.people.create!(body: "First person")
    person2 = user.people.create!(body: "Second person")

    assert_equal 2, user.people.count
    assert_includes user.people, person1
    assert_includes user.people, person2
  end

  test "person body attribute is saved correctly" do
    staff = staffs(:one)
    body_text = "This is a test person body"
    person = staff.people.create!(body: body_text)

    assert_equal person.body, body_text
  end

  test "destroying staff destroys associated people" do
    staff = Staff.create!(
      id: SecureRandom.uuid,
      public_id: Nanoid.generate(size: 21),
      staff_identity_status_id: "NONE"
    )
    person = staff.people.create!(body: "Staff member")
    person_id = person.id

    staff.destroy

    assert_nil Person.find_by(id: person_id)
  end

  test "destroying user destroys associated people" do
    user = User.create!(
      id: SecureRandom.uuid,
      public_id: Nanoid.generate(size: 21),
      user_identity_status_id: "ALIVE"
    )
    person = user.people.create!(body: "User profile")
    person_id = person.id

    user.destroy

    assert_nil Person.find_by(id: person_id)
  end

  test "different personalities can have people independently" do
    staff = staffs(:one)
    user = users(:one)

    staff.people.create!(body: "Staff person")
    user.people.create!(body: "User person")

    assert_equal 1, staff.people.count
    assert_equal 1, user.people.count
  end

  test "people are associated with correct personality" do
    staff = staffs(:one)
    user = users(:one)

    staff_person = staff.people.create!(body: "Staff person")
    user_person = user.people.create!(body: "User person")

    assert_equal staff, staff_person.personality
    assert_equal user, user_person.personality
  end
end
