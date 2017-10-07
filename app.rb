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
#mypage(じぶんのページ)表示
get '/profile' do
  @user = current_user
  @goals = Goal.where(user_id: @user.id)
  @follows = Follow.where(follower_id: @user.id)
  @followers = Follow.where(user_id: @user.id)
  erb :mypage
end

#userpage(他人のページ)表示
get '/user/:id' do
  @user = User.find(params[:id])
  @goals = Goal.where(user_id: params[:id])
  @follows = Follow.where(follower_id: params[:id])
  @followers = Follow.where(user_id: params[:id])
  @mutual_follower = Follow.where(user_id: params[:id]).where(follower_id: session[:user])
  erb :userpage
end

get '/profile/edit' do
  @user =  current_user
  erb :mypage_edit
end

post '/profile/edit' do
  user = current_user
  user.name = params[:name]
  user.email = params[:email]
  user.save(validate: false)
  redirect '/profile'
end

post '/user/:id/follow' do
  @follow = Follow.create(
    :user_id => params[:id],
    :follower_id => current_user.id
  )
  @notification = Notification.create(
    :status => 'follow',
    :user_id => current_user.id,
    :victim_id => params[:id]
  )
  redirect "user/#{params[:id]}"
end

post '/user/:id/follow/delete' do
  mutual_follower = Follow.where(user_id: params[:id]).where(follower_id: session[:user])
  mutual_follower.destroy_all
  redirect "user/#{params[:id]}"
end

get '/search' do
  erb :search_friends
end

post '/search/name' do
  @users = User.where(name: params[:name])
  erb :search_friends_result
end


#　ゴール周りに関する実装

#goalリスト
get '/goals' do
  goal = Goal.where(user_id: session[:user])
  @date = Date.today
  if goal.all.length > 0
    @goals = goal.all
  else
    @goals = goal.none
  end
  erb :list
end
#goal 作成
get '/goals/new' do
  erb :new_goals
end
#goal 作成
post '/goals' do
  @goal = current_user.goals.create(title: params[:title])
  @notification = Notification.create(
    :status => 'new_goal',
    :goal_id => @goal.id,
    :user_id => current_user.id
  )
  redirect '/goals'
end
#goal 削除
post '/goals/:id/delete' do
  goal = Goal.find(params[:id])
  goal.destroy
  redirect '/goals'
end
#goal 編集
get '/goals/:id/edit' do
  @goal = Goal.find(params[:id])
  erb :goal_edit
end
#goal 編集
post '/goals/:id' do
  goal = Goal.find(params[:id])
  goal.title = params[:title]
  goal.save
  redirect '/goals'
end
#goal 詳細
get  '/goals/:id' do
  @goal = Goal.find(params[:id])
  @checks = Check.where(goal_id: params[:id])
  erb :goal_show
end
#check 作成
post '/goals/:id/check' do
  @check = Check.create(
    :goal_id => params[:id],
    :checked_time => Time.now
  )
  @notification = Notification.create(
    :status => 'check',
    :goal_id => params[:id],
    :user_id => current_user.id
  )
  redirect '/goals'
end
#favorite 作成
post '/user/:user_id/goal/:goal_id/favorite' do
  goal = Goal.find(params[:goal_id])
  goal.favorite += 1
  goal.save
  @notification = Notification.create(
    :status => 'favorite',
    :goal_id => params[:id],
    :user_id => current_user.id,
    :victim_id => params[:user_id]
  )
  redirect "/user/#{params[:user_id]}"
end

#timeline表示
get '/notification' do
  @notifications = Notification.where(victim_id: session[:user])
  @users = []
  @notifications.each do |notification|
    user_name = User.find_by(id: notification.user_id ).name
    notification_status = notification.status
    hash = {}
    hash[:user_name] = user_name
    hash[:notification_status] = notification_status
    @users << hash
  end
  erb :notification
end

get '/timeline' do
  @friends = Follow.where(follower_id: session[:user])
  @actions = []
  @friends.each do |friend|
    @notifications = Notification.where(user_id: friend.user_id)
    users = []
    @notifications.each do |notification|
      user_name = User.find_by(id: notification.user_id).name
      notification_status = notification.status
      hash = {}
      hash[:user_name] = user_name
      hash[:notification_status] = notification_status
      hash[:notification_time] = notification.tim
      users << hash
    end
    @actions << users
  end
  erb :timeline
end
