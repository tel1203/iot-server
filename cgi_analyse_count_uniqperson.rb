#!/home/ylab/.rbenv/shims/ruby

##!/bin/sh
#    if [ -z $HOME ];then HOME=/Users/tel; export HOME; fi
#    PATH=$HOME/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:$PATH; export PATH
#    exec ruby -S -x $0 "$@"
##! ruby

#
# cgi_analyse_count_uniqperson.rb : return unique person number during date0 to date1 at specific location
#
# Usage:
# cgi_analyse_count_uniqperson.rb?date0=UNIXTIME&date1=UNIXTIME&location=KEY
#
#  date0: UNIXTIME, since
#  date1: UNIXTIME, until
#  location: sensor id
#
#"2016-02-24T00:00:00+09:00" 1456239600.0
#"2016-02-24T00:04:00+09:00" 1456239840.0

require 'cgi'
require 'json'
require 'time'
require './storage.rb'

def count_person(location, date0, date1)
  return if (date0 == nil or date1 == nil)
  return if (date0 > date1)

  storage = Storage.new
  output = storage._get_records_period(location, date0, date1)
  uids = Array.new 
  output.each do |data|
    uids.push(data["hashed_macaddress"])
  end
  uids.uniq!
  return (uids.size)
end

# location=wifi_node1&date0=1456239600.0&date1=1456239840.0
# location=wifi_node1&date0=1456239600.0&date1=1456326000.0
def debug()
  location="wifi_node4"
  date0=Time.parse("2016-02-18T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-19T00:00:00+09:00").to_f
  count_person(location, date0, date1)
end
#debug()
#exit



cgi = CGI.new

#puts("Content-type: text/html\n\n")
puts("Access-Control-Allow-Origin: *")
puts("Content-type: application/json\n\n")

location=cgi['location']
date0=cgi['date0'].to_f
date1=cgi['date1'].to_f
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

