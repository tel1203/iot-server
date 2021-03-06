#
# test_rest_post.rb : REST GET client for debug
#   v0.1 2016/02 : developped for REST getting
#
# usage:
#   ruby test_rest_get.rb www.sample.org 80
#

require 'uri'
require 'net/http'

#####
uri = URI.parse(ARGV[0])
http = Net::HTTP.new(uri.host, uri.port)

req = Net::HTTP::Get.new(uri.request_uri)
res = http.request(req)

if (ARGV[1] == "quiet") then
  puts res.body
else
  puts(">>> HTTP request")
  p req
  req.each do |name,value|
    puts(name + " : " + value)
  end
  puts req.body
  
  puts
  puts(">>> HTTP response")
  p res
  res.each do |name,value|
    puts(name + " : " + value)
  end
  puts res.body
end
  
