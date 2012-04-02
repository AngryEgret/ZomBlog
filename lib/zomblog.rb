require 'sinatra/base'
require 'sequel'
require 'haml'
require 'syntax/convertors/html'
require 'maruku'

class ZomBlog < Sinatra::Base
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

      require "#{APPLICATION_PATH}/lib/zomblog-control"
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
    
    def fix_dns
      if Config.dns_hash.include?("#{request.host}")
        return Config.dns_hash[request.host]
      end
    end
    
    def cache_for(time)
      response.headers['Cache-Control'] = "public, max-age=#{time.to_i}"
    end
  end

  ### Public

  get '/' do
    cache_for 60
	  posts = Post.reverse_order(:created_at).limit(10)
	  haml :index, :locals => { :posts => posts }, :layout => false
  end

  get '/past/:year/:month/:day/:slug/' do
    cache_for 60*60
	  post = Post.filter(:slug => params[:slug]).first
	  stop [ 404, "Page not found" ] unless post
	  @title = post.title
	  haml :post, :locals => { :post => post }
  end

  get '/past/:year/:month/:day/:slug' do
	  redirect "/past/#{params[:year]}/#{params[:month]}/#{params[:day]}/#{params[:slug]}/", 301
  end

  get '/past' do
    cache_for 60
	  posts = Post.reverse_order(:created_at)
	  @title = "Archive"
	  haml :archive, :locals => { :posts => posts }
  end

  get '/past/tags/:tag' do
    cache_for 60
	  tag = params[:tag]
	  posts = Post.filter(:tags.like("%#{tag}%")).reverse_order(:created_at).limit(30)
	  @title = "Posts tagged #{tag}"
	  haml :tagged, :locals => { :posts => posts, :tag => tag }
  end
  
  get '/about' do
    redirect Config.about_page, 301
  end

  get '/feed' do
    cache_for 60*60
	  @posts = Post.reverse_order(:created_at).limit(20)
	  content_type 'application/atom+xml', :charset => 'utf-8'
	  builder :feed
  end

  get '/rss' do
	  redirect '/feed', 301
  end

  ### Admin

  get '/auth' do
    response.headers['Cache-Control'] = 'no-cache'
	  haml :auth
  end

  post '/auth' do
    response.headers['Cache-Control'] = 'no-cache'
	  response.set_cookie(Config.admin_cookie_key, :value => Config.admin_cookie_value) if params[:password] == Config.admin_password
	  redirect '/'
  end

  get '/posts/new' do
    response.headers['Cache-Control'] = 'no-cache'
	  auth
	  haml :edit, :locals => { :post => Post.new, :url => '/posts' }
  end

  post '/posts' do
    response.headers['Cache-Control'] = 'no-cache'
	  auth
	  post = Post.new :title => params[:title], :tags => params[:tags], :body => params[:body], :created_at => Time.now, :slug => Post.make_slug(params[:title])
	  post.save
	  redirect post.url
  end

  get '/past/:year/:month/:day/:slug/edit' do
    response.headers['Cache-Control'] = 'no-cache'
	  auth
	  post = Post.filter(:slug => params[:slug]).first
	  stop [ 404, "Page not found" ] unless post
	  haml :edit, :locals => { :post => post, :url => post.url }
  end

  post '/past/:year/:month/:day/:slug/' do
    response.headers['Cache-Control'] = 'no-cache'
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
