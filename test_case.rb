# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source "https://rubygems.org"

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem "rails", github: "rails/rails", branch: "main"
  gem "sqlite3"
end

require "active_record"
require "minitest/autorun"
require "logger"

# This connection will do for database-independent bug reports.
ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
ActiveRecord::Base.logger = Logger.new(STDOUT)

ActiveRecord::Schema.define do
  create_table "groups", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.integer "group_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_id"], name: "index_users_on_group_id"
  end

  add_foreign_key "users", "groups"
end

class User < ActiveRecord::Base
  belongs_to :group, inverse_of: :users
end

class Group < ActiveRecord::Base
  has_many :users, inverse_of: :group
end

class BugTest < Minitest::Test
  def test_association_loads_correct_number_of_records
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