require 'bundler/setup'
Bundler.require
require 'sinatra/activerecord'
require './models'
require './user/user_controller'
require './goal/goal_controller'

get '/' do
  erb :index
end
use UserController
use GoalController

enable :sessions

configure :development do
  Bundler.require :development
  register Sinatra::Reloader
end

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end
