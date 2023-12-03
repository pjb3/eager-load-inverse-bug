# README

This app has a reproduction of an active record bug. To reproduce the bug, run:

    rails db:migrate
    rails test

You should see a failing test:

    GroupTest#test_association_loads_correct_number_of_records [/Users/paul/dev/rails/myapp/test/models/group_test.rb:20]:
    expected the first group to have 2 users.
    Expected: 2
      Actual: 3

The issue appears to be related to `inverse_of`. If you set up 2 models like this:

    class User < ApplicationRecord
      belongs_to :group, inverse_of: :users
    end

    class Group < ApplicationRecord
      has_many :users, inverse_of: :group
    end

Then create some data like this:

    group = Group.create!(name: "Test")

    john = User.create!(group: group, name: "John")
    jane = User.create!(group: group, name: "Jane")

You can then run this code in the console to see the issue:

    User.eager_load(:group => :users).where("users.id = ?", 1).first.group.users.map(&:name)

The result will be:

    ["John", "John", "Jane"]

This isn't what is expected. Since there are only 2 users in the group, it should be:

    ["John", "Jane"]
