require 'bundler'

Bundler.require(:default, :test)

require 'mongoid'
require 'active_model_serializers_cancancan'

require 'rspec/its'

Mongoid.configure do |config|
  config.connect_to "ams-test"
end
Mongo::Logger.logger.level = ::Logger::FATAL

class User
  include Mongoid::Document
  field :name
  has_many :projects
  has_many :categories
end

class Project
  include Mongoid::Document
  belongs_to :user, required: false
  belongs_to :category, required: false
  has_many :categories
end

class Category
  include Mongoid::Document
  belongs_to :user, required: false
  belongs_to :project, required: false
  has_many :projects
end

RSpec.configure do |config|
  config.before(:each) do
    user1 = User.create!(id: 1, name: "User1")
    user2 = User.create!(id: 2, name: "User2")

    c = Category.create!(project: Project.create!(user: user2))

    Project.create!(user: user1, category: c)
    Project.create!(user: user2, category: c)
  end

  config.after(:each) do
    User.delete_all
    Project.delete_all
    Category.delete_all
  end
end
