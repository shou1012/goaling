require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require 'sinatra/activerecord'
require './models'
require 'date'

enable :sessions

# configure :development do
#   Bundler.require :development
#   register Sinatra::Reloader
# end

helpers do
  def current_user
    User.find_by(id: session[:user])
  end
end

before '/goals' do
  if current_user.nil?
    redirect '/'
  end
end

get '/' do
  erb :index
end

# ユーザー周りに関する実装

get '/signin' do
  erb :sign_in
end

get '/signup' do
  erb :sign_up
end

post '/signin' do
  user = User.find_by(email: params[:email])
  if user && user.authenticate(params[:password])
    session[:user] = user.id
  end
  redirect '/goals'
end

post '/signup' do
  user = User.create(
    name: params[:name],
    email: params[:email],
    password: params[:password],
    password_confirmation: params[:password_confirmation]
  )
  if user.persisted?
    session[:user] = user.id
  end
  redirect '/goals'
end

get '/signout' do
  session[:user] = nil
  redirect '/'
end

# def user_params
#   params.require(:user).permit(:name, :email, :password, :password_confirmation)
# end


#　ゴール周りの実装

get '/goals' do
  if Goal.all.length > 0
    @goals = Goal.all
  else
    @goals = Goal.none
  end
  erb :list
end

get '/goals/new' do
  erb :new_goals
end

post '/goals' do
  current_user.goals.create(title: params[:title])
  redirect '/goals'
end

post '/goals/:id/delete' do
  goal = Goal.find(params[:id])
  goal.destroy
  redirect '/goals'
end

get '/goals/:id/edit' do
  @goal = Goal.find(params[:id])
  erb :goal_edit
end

post '/goals/:id' do
  goal = Goal.find(params[:id])
  goal.title = params[:title]
  goal.save
  redirect '/goals'
end

get  '/goals/:id' do
  @goal = Goal.find(params[:id])
  @checks = Check.where(goal_id: params[:id])
  erb :goal_show
end

post '/goals/:id/check' do
  @check = Check.create(
    :goal_id => params[:id],
    :checked_time => Time.now
  )
  redirect '/goals'
end
