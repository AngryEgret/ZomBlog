APPLICATION_PATH = File.expand_path(File.join(File.dirname(__FILE__), "."));

require 'rubygems'
require 'ostruct'
require "#{APPLICATION_PATH}/lib/zomblog"

Config = OpenStruct.new(
	:title => 'zomblog',
	:author => 'you',
	:url_base => 'http://localhost:4567/',
	:admin_password => 'changeme',
	:admin_cookie_key => 'key_here',
	:admin_cookie_value => '51d6d976913ace58',
	:disqus_shortname => 'replace',
	:about_page => 'uri_here',
	:dns_hash => {"yourblog.com" => 'My Blog', "alsoyourblog.com" => 'Still Mine'}
)

ZomBlog.configure

run ZomBlog.new
