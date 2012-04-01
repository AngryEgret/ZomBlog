APPLICATION_PATH = File.expand_path(File.join(File.dirname(__FILE__), "."));

require 'rubygems'
require 'ostruct'
require "#{APPLICATION_PATH}/lib/zomblog"

Config = OpenStruct.new(
	:title => 'Zombie Inferno',
	:author => 'Ryan Greget',
	:url_base => 'http://localhost:4567/',
	:admin_password => 'changeme',
	:admin_cookie_key => 'scanty_admin',
	:admin_cookie_value => '51d6d976913ace58',
	:disqus_shortname => 'zombie-inferno',
	:dns_array => ['zombie-inferno.com' => 'Zombie Inferno', 'ottom8.com' => 'OttoM8', 'six60six.com' => 'six60six']
)

ZomBlog.configure

run ZomBlog.new
