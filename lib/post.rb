# - Post - #
class Post < Sequel::Model
  plugin :schema

  unless table_exists?
	  set_schema do
		  primary_key :id
		  text :title
		  text :body
		  text :slug
		  text :tags
		  timestamp :created_at
	  end
	  create_table
  end

  def url
	  d = created_at
	  "/past/#{d.year}/#{d.month}/#{d.day}/#{slug}/"
  end

  def full_url
	  Config.url_base.gsub(/\/$/, '') + url
  end

  def body_html
	  to_html(body)
  end

  def summary
	  @summary ||= body.match(/(.{200}.*?\n)/m)
	  @summary || body
  end

  def summary_html
	  to_html(summary.to_s)
  end

  def more?
	  @more ||= body.match(/.{200}.*?\n(.*)/m)
	  @more
  end

  def linked_tags
	  tags.split.inject([]) do |accum, tag|
		  accum << "<a href=\"/past/tags/#{tag}\">#{tag}</a>"
	  end.join(" ")
  end

  def self.make_slug(title)
	  title.downcase.gsub(/ /, '_').gsub(/[^a-z0-9_]/, '').squeeze('_')
  end

  ########

  def to_html(markdown)
  	RDiscount.new(markdown, :smart, :filter_html).to_html
  end

  def split_content(string)
	  parts = string.gsub(/\r/, '').split("\n\n")
	  show = []
	  hide = []
	  parts.each do |part|
		  if show.join.length < 100
			  show << part
		  else
			  hide << part
		  end
	  end
	  [ to_html(show.join("\n\n")), hide.size > 0 ]
  end
end

