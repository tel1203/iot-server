# coding: utf-8
require "net/http"
require "uri"
require "json"

class IoTAccess
def initialize(url="http://localhost:55555/iot/")
  @url = url
end

def put(key, data)
  uri = URI.parse(@url+key)
  http = Net::HTTP.new(uri.host, uri.port)
  req = Net::HTTP::Post.new(uri.request_uri)
  req["Content-Type"] = "application/json"
  req.body = data
  res = http.request(req)

  return (res)
end

def get(key)
  uri = URI.parse(@url+key)
  res = Net::HTTP.start(uri.host, uri.port) do |http|
        http.open_timeout = 5
        http.read_timeout = 10
        http.get(uri.request_uri)
  end

  return (res)
end
end

