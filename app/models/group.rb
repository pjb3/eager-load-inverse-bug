class Group < ApplicationRecord
  has_many :users, inverse_of: :group
end
