#
# iot-server.rb : IoT Server with REST-API for sensors/actuators
#   v0.2 2016/02 : make storage on mongoDB
#   v0.1 2015/11 : just storage with REST-API on local FS
#
# usage:
#   ruby iot-server.rb
#

Version="0.1"
require 'uri'
require 'json'
require 'webrick'
require './lib-generic.rb'
require './storage.rb'

module RestDataProcess
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

  def save_records(key, records)
    records.each do |record|
      @storage.put(key, record)
    end
  end

  def load_records(key, query=nil)
    printf("load_record(): key:[%s] query:[%s]\n", key, query)
    data = @storage.get(key, query)

    return (data)
  end
end

class RestDataServlet < WEBrick::HTTPServlet::AbstractServlet
  include RestDataProcess

  def initialize(server, storage)
    super server
    @storage = storage
  end

  def do_POST (req, res)
    key = req.path_info[1, req.path_info.length-1]
    input = JSON.parse(req.body)

    # ERROR: no key spcified in URL
    if (key == nil or key == "") then
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
    if (key != input["key"]) then
      puts("Error: Keys difference")
      res.status = 400 # 400: Bad Request
      return
    end

    # Make data records for DB registration
    p input
    records = make_records_input(input)
    save_records(key, records)

#    output = req.body
#    res.body = output
    res['Location'] = req.path
#    res.status = 400 # 400: Bad Request
  end

  def do_GET (req, res)
    key = req.path_info[1, req.path_info.length-1]
    data = load_records(key, req.query)
p data

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
  

# Read option
option=parse_option()
port = option[:port]==nil ? 55555 : option[:port]
@server = launch_webrick(".", nil, port)
    
# Launch Server
RESTURL_BASE="/api/v1"
storage = Storage.new
@server.mount(RESTURL_BASE+"/data", RestDataServlet, storage)
@server.start

