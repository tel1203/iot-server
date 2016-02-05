#
# iot-server.rb : IoT Server with REST-API for sensors/actuators
#   v0.1 2015/11 : just storage with REST-API
#
# usage:
#   ruby iot-server.rb
#

Version="0.1"
require 'uri'
require 'json'
require './lib-generic.rb'
require './storage.rb'

require 'webrick'


class MongoDB
  def initialize()
  end

  def put(key, data)
  end

  def get(key)
  end
end


module RestDataProcess
  def extract_postkey(uripath)
#    return (uripath.sub(/^\/iot\//, ""))
    return (uripath.strip.split("/")[-1])
  end

  def make_records_input(input)
  
    # extract keys in header
    keys_header = input.keys - ["data"]

    # Prepare data in header for common data
    data_header = Hash.new # data in header
    data_header["received_at"] = Time.now.iso8601
    keys_header.each do |k|
      data_header[k] = input[k]
    end
  
    data_array = input["data"]
    record_array = Array.new
    data_array.each do |data|
      # Create data record for DB registration
      record = data_header.dup
      record["data"] = data

      record_array.push(record)
    end
  
    return (record_array)
  end

  def save_records(records)
#    @storage.put(key_url, records)
  end

  def load_records(key, query=nil)
#    data = @storage.get(key)
  end
end

class RestDataServlet < WEBrick::HTTPServlet::AbstractServlet
  include RestDataProcess

  def initialize(server, storage)
    super server
    @storage = storage
  end

  def do_POST (req, res)
    key_url = extract_postkey(req.path)
    input = JSON.parse(req.body)

    # ERROR: no key spcified in URL
    if (key_url == nil or key_url == "") then
      puts("Error: No key in URL")
      res.status = 400 # 400: Bad Request
      return
    end

    # ERROR: no key spcified in input data
    if (input["key"] == nil) then
      puts("Error: No key in input")
      res.status = 400 # 400: Bad Request
      return
    end

    # ERROR: different key specified on URL and input data
    if (key_url != input["key"]) then
      puts("Error: Keys difference")
      res.status = 400 # 400: Bad Request
      return
    end

    # Make data records for DB registration
    records = make_records_input(input)
    save_records(records)

#    output = req.body
#    res.body = output
    res['Location'] = req.path
#    res.status = 400 # 400: Bad Request
  end

  def do_GET (req, res)
    key = extract_postkey(req.path)
    load_records(key, query=nil)

    # ERROR: no data in the URL
    if (data == nil) then
      puts("Error: No data in the URL")
      res.status = 404 # 404: Not Found
      return
    end

    res['Content-Type:'] = 'application/json'
    res.body = data.to_json
  end
end
  
#storage = Storage.new
storage = MongoDB.new

option=parse_option()
port = option[:port]==nil ? 55555 : option[:port]
@server = launch_webrick(".", nil, port)
    
# サーバを開始する
RESTURL_BASE="/api/v1"
@server.mount(RESTURL_BASE+"/data", RestDataServlet, storage)
@server.start

