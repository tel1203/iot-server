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
req["Content-Type"] = "application/json" # httpリクエストヘッダの追加
req.body = jsondata # リクエストボデーにJSONをセット
res = http.request(req)

p res
res.each do |name,value|
  puts(name + " : " + value)
end
p res.body

