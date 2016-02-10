#
# test_rest_post.rb : REST POST client for debug
#   v0.1 2016/02 : developped for REST posting
#
# usage:
#   ruby test_rest_post.rb FILENAME www.sample.org 80
#

require 'uri'
require 'net/http'

fname = ARGV[1]
jsondata = ""
if (fname != nil) then
  f=open(fname, "r")
  jsondata = f.read
end

#p jsondata

uri = URI.parse(ARGV[0])
http = Net::HTTP.new(uri.host, uri.port)
req = Net::HTTP::Post.new(uri.request_uri)
res = http.request(req)

puts(">>> HTTP request")
req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
req["Content-Length"] = jsondata.size.to_s
req.body = jsondata # リクエストボデーにJSONをセット

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

