require 'json'

jsondata= <<EOS
{
  "data": [
    {
      "rssi": -187,
      "oui": "344df7",
      "hashed_macaddress": "ab5aaa3a8940f43fb4109184d089a324d34eb68e",
      "created_at": "2015-08-15T18:01:00+09:00"
    },
    {
      "rssi": -185,
      "oui": "344df7",
      "hashed_macaddress": "ab5aaa3a8940f43fb4109184d089a324d34eb68e",
      "created_at": "2015-08-15T18:01:00+09:00"
    },
    {
      "rssi": -187,
      "oui": "344df7",
      "hashed_macaddress": "ab5aaa3a8940f43fb4109184d089a324d34eb68e",
      "created_at": "2015-08-15T18:01:00+09:00"
    },
    {
      "rssi": -187,
      "oui": "344df7",
      "hashed_macaddress": "ab5aaa3a8940f43fb4109184d089a324d34eb68e",
      "created_at": "2015-08-15T18:01:00+09:00"
    },
    {
      "rssi": -205,
      "oui": "10417f",
      "hashed_macaddress": "954a9b08932db7e0ee083d13c59969a080f005ba",
      "created_at": "2015-08-15T18:01:35+09:00"
    }
  ],
  "type": "wifi_person_finder",
  "key": "wifi_node1"
}

EOS

def parse_input(jsondata)
  input = JSON.parse(jsondata)

  # extract keys in header
  keys_header = input.keys - ["data"]
  data_header = Hash.new
  keys_header.collect do |k|
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

p parse_input(jsondata)
exit

#p jsondata
#p JSON.parse(jsondata)

require "./iot-access.rb"

serv=IoTAccess.new()

# Ex: data registration
key=JSON.parse(jsondata)["key"]
res=serv.put(key, jsondata)
p res

## Ex: data reading
#res=serv.get("ABCDEF")
#p res

