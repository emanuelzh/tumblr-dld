# Tumblr site grabber
# Download all images from a tumblr site
# Emanuel Zámano H. 2014

require('tumblr_client')
require('mechanize')

# api authentication configuration
Tumblr.configure do |config|
	config.consumer_key = ""
	config.consumer_secret = ""
	#config.oauth_token = ""
	#config.oauth_token_secret = ""
end

#mechanize for the downloads
agent = Mechanize.new
agent.pluggable_parser.default = Mechanize::Download

#the actual tumblr API client
client = Tumblr::Client.new(:client => :httpclient)


#obtain number of photos 
info = client.posts(ARGV[0], :type => "photo", "limit" => 1, "offset" =>0)
total = info["total_posts"]

puts "Total: #{total}"
 
#calculate pages
pages = total / 20

#calculate the extra request
extra = total % 20
puts "Pages: #{pages} of 20 photos and #{extra} extra"

#go for the first 20

offset = 0
pages = pages - 1

#all pages loop
for i in 0..pages
   offset = i * 20
   posts = client.posts(ARGV[0], :type => "photo", "limit" => 20, "offset" =>offset)
   posts["posts"].each {|post| 
     da_id = post["id"]
     da_photo = post["photos"][0]["original_size"]
     da_url = da_photo["url"]
     da_ext = da_url[da_url.length - 3, da_url.length - 1]
     #save the image using it's id as name
     agent.get(da_url).save("photos/#{da_id}.#{da_ext}")
     #add a 2 sec delay to overcome rate limits
     #sleep(2)
  }
end

#deal with extra posts
if extra > 0
   offset = i * 20
   posts = client.posts(ARGV[0], :type => "photo", "limit" => 20, "offset" =>offset)
   posts["posts"].each {|post|
     da_id = post["id"]
     da_photo = post["photos"][0]["original_size"]
     da_url = da_photo["url"]
     da_ext = da_url[da_url.length - 3, da_url.length - 1]
     #save the image using it's id as name
     agent.get(da_url).save("photos/#{da_id}.#{da_ext}")
     #add a 2 sec delay to overcome rate limits
     #sleep(2)
  }
end

puts "Done !"

