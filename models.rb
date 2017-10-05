require 'bundler/setup'
Bundler.require

if development?
  ActiveRecord::Base.establish_connection("sqlite3:db/development.db")
end

class User < ActiveRecord::Base
  has_secure_password
  validates :name,
  presence: true,
  format: { with: /\A\w+\z/ }
  validates :password,
  length: { in: 5..10 }
  has_many :goals
  has_many :follows
  has_many :notifications
end

class Goal < ActiveRecord::Base
  validates :title,
    presence: true
  belongs_to :user
  has_many :checks
  has_many :notifications
end

class Check < ActiveRecord::Base
  belongs_to :goal
end

class Follow < ActiveRecord::Base
  belongs_to :user
end

class Notification < ActiveRecord::Base
  belongs_to :user
  belongs_to :goal
end
