#!/home/ylab/.rbenv/shims/ruby

##!/bin/sh
#    if [ -z $HOME ];then HOME=/Users/tel; export HOME; fi
#    PATH=$HOME/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:$PATH; export PATH
#    exec ruby -S -x $0 "$@"
##! ruby

#
# cgi_analyse_count_trajectories.rb : return user's trajectories during date0 to date1 in locations
#
# Usage:
# cgi_analyse_count_trajectories.rb?date0=UNIXTIME&date1=UNIXTIME&locations=wifi_node1,wifi_node2,wifi_node3
#
#  date0: UNIXTIME, since
#  date1: UNIXTIME, until
#  locations: sensor id, sensor id, ...
#
#"2016-02-24T00:00:00+09:00" 1456239600.0
#"2016-02-24T00:04:00+09:00" 1456239840.0

require 'cgi'
require 'json'
require 'time'
require './storage.rb'

def dump_obj(name, obj)
  output = Base64.b64encode( Marshal.dump(obj) )

  f=open(dir+"/"+name+".obj", "w")
  f.puts(output)
  f.close
end

def restore_obj(name)
  f=open(dir+"/"+name+".obj", "r")
  input = f.gets
  f.close

  obj = Marshal.load( Base64.decode64(input) )

  return (obj)
end


def trajectories(locations, date0, date1)
  return if (date0 == nil or date1 == nil)
  return if (date0 > date1)

  storage = Storage.new
  i = 0
  user = Hash.new(nil)
  locations.split(",").each do |location|
    output = storage._get_records_period(location, date0, date1)
#p output.size
    output.each do |data|
      user[data["hashed_macaddress"]] = Array.new if (user[data["hashed_macaddress"]] == nil)
      user[data["hashed_macaddress"]].push([('A'.ord+i).chr, Time.parse(data["created_at"]).to_f])
    end
#p user.size
    i += 1
  end

  # 
  name = sprintf("%s %f %f", locations, date0, date1)

  i = 0
  trajectory = Hash.new(0)
  user.each_pair do |k, d|
    traj = d.sort {|a,b| a[1] <=> b[1]}
    traj2 = traj.collect {|x| x[0]}
    traj3 = traj2.join.squeeze

    trajectory[traj3] += 1
  end

#  i = 0
#  trajectory.each do |traj|
#    printf("%d:%s\n", i, traj)
#    i += 1
#  end

  data = Hash.new
  data["data"] = trajectory.to_a

  return (data)
end

# For debug
def debug
  locations = "wifi_node1,wifi_node2,wifi_node3,wifi_node4"
  date0=Time.parse("2016-02-18T00:00:00+09:00").to_f
#  date1=Time.parse("2016-02-19T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-18T00:20:00+09:00").to_f
p date0
p date1
  data = trajectories(locations, date0, date1)
  p data.to_json
end
#debug() # For CLI debugging
#exit

# 2016-02-24T00:00:00+09:00, 2016-02-24T02:00:00+09:00
# locations=wifi_node1,wifi_node2,wifi_node3,wifi_node4&date0=1456239600.0&date1=1456246800.0
# 2016-02-25T00:00:00+09:00, 2016-02-25T02:00:00+09:00
# locations=wifi_node1,wifi_node2,wifi_node3,wifi_node4&date0=1456326000.0&date1=1456333200.0
cgi = CGI.new

#puts("Content-type: text/html\n\n")
puts("Access-Control-Allow-Origin: *")
puts("Content-type: application/json\n\n")

locations=cgi['locations']
date0=cgi['date0'].to_f
date1=cgi['date1'].to_f
if (locations=="" or date0=="" or date1=="") then
  data = nil
else
  data = trajectories(locations, date0, date1)
end

output = Hash.new
output["locations"] = locations
output["date0"] = date0
output["date1"] = date1
output["since"] = Time.at(date0).iso8601
output["until"] = Time.at(date1).iso8601
output["data"] = data

puts(output.to_json)
exit

###
#require 'time'
#date = "2015-08-02T18:01:00+09:00"
#unixtime = Time.parse(date).to_i
#p unixtime
## => 1438506060
#p Time.at(unixtime)
## => 2015-08-02 19:01:00 +0900
#p Time.at(unixtime).iso8601
## => "2015-08-02T19:01:00+09:00"

