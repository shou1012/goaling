require 'bundler/setup'
Bundler.require
require 'sinatra/activerecord'
require './models'

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

get '/' do
  erb :index
end

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
