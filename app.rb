require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

set :database, "sqlite3:barber.db"

class Clients < ActiveRecord::Base
  validates :name, presence: true, length: { in: 3..50 }
  validates :phone, presence: true
  validates :datestamp, presence: true
  validates :barber, presence: true
  validates :color, presence: true
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
  @c_new = Clients.new
  erb :appoint
end

post '/appoint' do
  @c_new = Clients.new params[:clients]
  if @c_new.save
    redirect to '/'
  else
    @error = "Error somewhere: " + @c_new.errors.full_messages.first
    erb :appoint
  end
end

get '/barber/:id' do
  @barber = Barbers.find(params[:id])
  @app_list = Clients.find_by barber: @barber.name
  erb :barber
end

get '/bookings' do
  @appnt_list = Clients.order "created_at DESC"
  erb :bookings
end

get '/client/:id' do
  @client = Clients.join("inner join barbers on clients.barber=barbers.id where id=?",[params[:id]])
  erb :client
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
