require 'bundler/setup'
Bundler.require
require 'sinatra/activerecord'
require './models'

class GoalController < Sinatra::Base
  get '/goals/new' do
    erb :new
  end
  post '/goals' do
    current_user.goals.create(title: params[:title])
    redirect '/'
  end

end
