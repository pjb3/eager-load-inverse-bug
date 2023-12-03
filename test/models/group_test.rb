require "test_helper"

class GroupTest < ActiveSupport::TestCase
  test "association loads correct number of records" do
    # Create a group
    group = Group.create!(name: "Test")

    # Create two users in the group
    john = User.create!(group: group, name: "John")
    jane = User.create!(group: group, name: "Jane")

    group = Group.find(group.id)
    john = User.find(john.id)
    jane = User.find(jane.id)

    # When you load the use then get the size of the users in the group, you correctly get 2
    assert_equal 2, john.group.users.map(&:name).size

    # But when you eager_load the first user, there are 3 users in the group
    assert_equal 2, User.eager_load(:group => :users).where("users.id = ?", 1).first.group.users.map(&:name).size,
      "expected the first group to have 2 users"
  end
end
