#
# iot-server.rb : IoT Server with REST-API for sensors/actuators
#   v0.1 2015/11 : just storage with REST-API
#
# usage:
#   ruby iot-server.rb
#

Version="0.1"
require 'uri'
require './lib-generic.rb'
require './storage.rb'

require 'webrick'

$st = Storage.new
class RestServlet < WEBrick::HTTPServlet::AbstractServlet
  def do_POST (req, res)
    key = req.path.sub(/^\/iot\//, "")
    $st.put(key, req.body)

    output = req.body
    res.body = output
  end

  def do_GET (req, res)
    key = req.path.sub(/^\/iot\//, "")
    data = $st.get(key)

    res['Content-Type:'] = 'application/json'
    res.body = data.to_json
    p res
  end
end

option=parse_option()
port = option[:port]==nil ? 55555 : option[:port]
server = launch_webrick(".", nil, port)
p option

server.mount('/iot', RestServlet)

# サーバを開始する
server.start
