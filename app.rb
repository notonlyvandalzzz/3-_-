require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barber.db"

class Clients < ActiveRecord::Base
end

class Barbers < ActiveRecord::Base
end


configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before do
  @barbers = Barbers.order "created_at DESC"
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb :index
end

get '/appoint' do
    erb :appoint
end

post '/appoint' do
  # @username = params[:username]
  # @phone = params[:phone]
  # @datetime = params[:datetime]
  # @barber = params[:barber]
  # @color = params[:colorpicker]

  c_new = Clients.new params[:clients]

  # c_new = Clients.new
  # c_new.name = @username
  # c_new.phone = @phone
  # c_new.datestamp = @datetime
  # c_new.barber = @barber
  # c_new.color = @color
  c_new.save
  redirect to '/'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  if params['username'] == 'admin' && params['passwd'] == 'mypass'
    session[:identity] = params['username']
    where_user_came_from = session[:previous_url] || '/'
    redirect to where_user_came_from
  else
    @error = 'Wrong login/password pair'
    halt erb(:login_form)
  end
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
  erb :secret_area
end
