class User < ApplicationRecord
  belongs_to :group, inverse_of: :users
end
