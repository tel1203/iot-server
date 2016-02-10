#!/bin/sh
    if [ -z $HOME ];then HOME=/Users/tel; export HOME; fi
    PATH=$HOME/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:$PATH; export PATH
    exec ruby -S -x $0 "$@"
#! ruby

#
# cgi_analyse_count_trip.rb : return unique person number moving from location0 to location1 during date0 to date1
#
# Usage:
# cgi_analyse_count_trip.rb?lcation0=KEY&location1=KEY&date0=UNIXTIME&date1=UNIXTIME
#
#  date0: UNIXTIME, since
#  date1: UNIXTIME, until
#  location0: sensor id
#  location1: sensor id
#

require 'cgi'
require 'json'
require 'time'
require './storage.rb'

def count_person(location, date0, date1)
  return if (date0 == nil or date1 == nil)
  return if (date0 > date1)

  storage = Storage.new
  fname = storage.make_filename(location)
 
  uids = Array.new 
  f = open(fname, "r")
  while (line=f.gets) do
    record = JSON.parse(line)
    data = record["value"]["data"]
    if (Time.parse(data["created_at"]).to_i >= date0 and
        Time.parse(data["created_at"]).to_i < date1) then
      uids.push(data["hashed_macaddress"])
    end
  end

  uids.uniq!

  return (uids.size)
end

# location=wifi_node1&date0=1438506060&date1=1438592460
cgi = CGI.new

#puts("Content-type: text/html\n\n")
puts("Content-type: application/json\n\n")

location=cgi['location']
date0=cgi['date0'].to_i
date1=cgi['date1'].to_i
if (location=="" or date0=="" or date1=="") then
  count = nil
else
  count = count_person(location, date0, date1)
end

output = Hash.new
output["location"] = location
output["date0"] = date0
output["date1"] = date1
output["since"] = Time.at(date0).iso8601
output["until"] = Time.at(date1).iso8601
output["count"] = count

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

