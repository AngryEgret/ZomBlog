require 'sinatra/base'
require 'sequel'
require 'haml'
require 'syntax/convertors/html'
require 'maruku'

class ZombieCMS < Sinatra::Base
      set :static, true
      set :public_directory, "#{APPLICATION_PATH}/public"
  class << self
    attr_accessor :credentials

    def configure
      set :lock, true
      set :threaded, false
      set :views, "#{APPLICATION_PATH}/views"
      set :haml, { :format => :html5 }
      set :static, true
      set :environment, ENV['RACK_ENV']
      set :public_directory, "#{APPLICATION_PATH}/public"
      set :root, APPLICATION_PATH

    	Sequel.connect('sqlite://blog.db')

      require "#{APPLICATION_PATH}/lib/zombiecms-control"
      require "#{APPLICATION_PATH}/lib/post"
    end
  end

  helpers do
	  def admin?
		  request.cookies[Config.admin_cookie_key] == Config.admin_cookie_value
	  end

	  def auth
		  stop [ 401, 'Not authorized' ] unless admin?
	  end

    def partial(page, options={})
      haml page.to_sym, options.merge!(:layout => false)
    end
  end

  ### Public

  get '/' do
	  posts = Post.reverse_order(:created_at).limit(10)
	  erb :index, :locals => { :posts => posts }, :layout => false
  end

  get '/past/:year/:month/:day/:slug/' do
	  post = Post.filter(:slug => params[:slug]).first
	  stop [ 404, "Page not found" ] unless post
	  @title = post.title
	  erb :post, :locals => { :post => post }
  end

  get '/past/:year/:month/:day/:slug' do
	  redirect "/past/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:slug]}/", 301
  end

  get '/past' do
	  posts = Post.reverse_order(:created_at)
	  @title = "Archive"
	  erb :archive, :locals => { :posts => posts }
  end

  get '/past/tags/:tag' do
	  tag = params[:tag]
	  posts = Post.filter(:tags.like("%#{tag}%")).reverse_order(:created_at).limit(30)
	  @title = "Posts tagged #{tag}"
	  erb :tagged, :locals => { :posts => posts, :tag => tag }
  end

  get '/feed' do
	  @posts = Post.reverse_order(:created_at).limit(20)
	  content_type 'application/atom+xml', :charset => 'utf-8'
	  builder :feed
  end

  get '/rss' do
	  redirect '/feed', 301
  end

  ### Admin

  get '/auth' do
	  erb :auth
  end

  post '/auth' do
	  set_cookie(Blog.admin_cookie_key, Blog.admin_cookie_value) if params[:password] == Blog.admin_password
	  redirect '/'
  end

  get '/posts/new' do
	  auth
	  erb :edit, :locals => { :post => Post.new, :url => '/posts' }
  end

  post '/posts' do
	  auth
	  post = Post.new :title => params[:title], :tags => params[:tags], :body => params[:body], :created_at => Time.now, :slug => Post.make_slug(params[:title])
	  post.save
	  redirect post.url
  end

  get '/past/:year/:month/:day/:slug/edit' do
	  auth
	  post = Post.filter(:slug => params[:slug]).first
	  stop [ 404, "Page not found" ] unless post
	  erb :edit, :locals => { :post => post, :url => post.url }
  end

  post '/past/:year/:month/:day/:slug/' do
	  auth
	  post = Post.filter(:slug => params[:slug]).first
	  stop [ 404, "Page not found" ] unless post
	  post.title = params[:title]
	  post.tags = params[:tags]
	  post.body = params[:body]
	  post.save
	  redirect post.url
  end
end
