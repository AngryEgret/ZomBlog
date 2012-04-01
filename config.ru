APPLICATION_PATH = File.expand_path(File.join(File.dirname(__FILE__), "."));

require 'rubygems'
require 'ostruct'
require "#{APPLICATION_PATH}/lib/zombiecms"

Config = OpenStruct.new(
	:title => 'a scanty blog',
	:author => 'Ryan Greget',
	:url_base => 'http://localhost:4567/',
	:admin_password => 'changeme',
	:admin_cookie_key => 'scanty_admin',
	:admin_cookie_value => '51d6d976913ace58',
	:disqus_shortname => 'zombie-inferno'
)

ZombieCMS.configure

run ZombieCMS.new
