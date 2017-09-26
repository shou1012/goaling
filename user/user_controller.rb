require 'bundler/setup'
Bundler.require
require 'sinatra/activerecord'
require './models'

class UserController < Sinatra::Base

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
    redirect '/goals/new'
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
    redirect './goal/list'
  end

  get '/signout' do
    session[:user] = nil
    redirect '/'
  end

  private
    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation)
    end

end
