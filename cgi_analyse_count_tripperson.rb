#!/home/ylab/.rbenv/shims/ruby

##!/bin/sh
#    if [ -z $HOME ];then HOME=/Users/tel; export HOME; fi
#    PATH=$HOME/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:$PATH; export PATH
#    exec ruby -S -x $0 "$@"
##! ruby

#
# cgi_analyse_count_tripperson.rb : return unique person number during date0 to date1 in location0 and location1
#
# Usage:
# cgi_analyse_count_tripperson.rb?date0=UNIXTIME&date1=UNIXTIME&location0=KEY&location1=KEY
#
#  date0: UNIXTIME, since
#  date1: UNIXTIME, until
#  location0: sensor id
#  location1: sensor id
#
#"2016-02-24T00:00:00+09:00" 1456239600.0
#"2016-02-24T00:04:00+09:00" 1456239840.0

require 'cgi'
require 'json'
require 'time'
require './storage.rb'

def count_person_trip(locationA, locationB, date0, date1)
  return if (date0 == nil or date1 == nil)
  return if (date0 > date1)

  storage = Storage.new
  output0 = storage._get_records_period(locationA, date0, date1)
  output1 = storage._get_records_period(locationB, date0, date1)

  user = Hash.new(nil)
  output0.each do |data|
    user[data["hashed_macaddress"]] = Array.new if (user[data["hashed_macaddress"]] == nil)
    user[data["hashed_macaddress"]].push(["A", Time.parse(data["created_at"]).to_f])
  end

  output1.each do |data|
    user[data["hashed_macaddress"]] = Array.new if (user[data["hashed_macaddress"]] == nil)
    user[data["hashed_macaddress"]].push(["B", Time.parse(data["created_at"]).to_f])
  end

  count_Aonly = 0
  count_Bonly = 0
  count_A = 0
  count_B = 0
  count_AB = 0
  count_BA = 0
  count_AA = 0
  count_BB = 0
  count_AandB = 0

  user.each_pair do |k, d|
    traj = d.sort {|a,b| a[1] <=> b[1]}
    traj2 = traj.collect {|x| x[0]}
    traj3 = traj2.join

    if (traj3 =~ /^A*$/) then
      count_Aonly += 1
    end
    if (traj3 =~ /^B*$/) then
      count_Bonly += 1
    end
    if (traj3 =~ /A/) then
      count_A += 1
    end
    if (traj3 =~ /B/) then
      count_B += 1
    end
    if (traj3 =~ /^A.*B$/) then
      count_AB += 1
    end
    if (traj3 =~ /^B.*A$/) then
      count_BA += 1
    end
    if (traj3 =~ /^A.*B.*A$/) then
      count_AA += 1
    end
    if (traj3 =~ /^B.*A.*B$/) then
      count_BB += 1
    end
    if (traj3 =~ /A/ and traj3 =~ /B/) then
      count_AandB += 1
    end

  end

  data = Hash.new
  data["count_A"] = count_A
  data["count_B"] = count_B
  data["count_A_only"] = count_Aonly
  data["count_B_only"] = count_Bonly
  data["count_AtoB"] = count_AB
  data["count_AtoA"] = count_AA
  data["count_FromA"] = count_AA+count_AB
  data["count_LeaveA"] = count_AA+count_BA
  data["count_BtoA"] = count_BA
  data["count_BtoB"] = count_BB
  data["count_FromB"] = count_BA+count_BB
  data["count_LeaveB"] = count_BB+count_AB
  data["count_AandB"] = count_AandB

  return (data)

  # Output Result for debug
  printf("A  : %d/%d\n", count_Aonly, count_A)
  printf("B  : %d/%d\n", count_Bonly, count_B)
  printf("A&B: %d\n", count_AandB)
  # A and B = A - Aonly = B - Bonly
  #         = A->B + A->A + B->A + B->B
  printf("From  A: %d\n", count_AB+count_AA)
  printf("Leave A: %d\n", count_BA+count_AA)
  printf("  A->A: %d\n", count_AA)
  printf("  A->B: %d\n", count_AB)
  printf("From  B: %d\n", count_BB+count_BA)
  printf("Leave B: %d\n", count_AB+count_BB)
  printf("  B->A: %d\n", count_BA)
  printf("  B->B: %d\n", count_BB)
  
end

# For debug
def debug
  location0 = "wifi_node1"
  location1 = "wifi_node2"

  date0=Time.parse("2016-02-21T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-22T00:00:00+09:00").to_f
  count = count_person_trip(location0, location1, date0, date1)
puts
  date0=Time.parse("2016-02-22T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-23T00:00:00+09:00").to_f
  count = count_person_trip(location0, location1, date0, date1)
puts
  date0=Time.parse("2016-02-23T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-24T00:00:00+09:00").to_f
  count = count_person_trip(location0, location1, date0, date1)
puts
  date0=Time.parse("2016-02-24T00:00:00+09:00").to_f
  date1=Time.parse("2016-02-25T00:00:00+09:00").to_f
  count = count_person_trip(location0, location1, date0, date1)
end
#debug() # For CLI debugging
#exit

# 2016-02-24T00:00:00+09:00, 2016-02-25T00:00:00+09:00
# locationA=wifi_node1&locationB=wifi_node2&date0=1456239600.0&date1=1456326000.0
cgi = CGI.new

#puts("Content-type: text/html\n\n")
puts("Access-Control-Allow-Origin: *")
puts("Content-type: application/json\n\n")

locationA=cgi['locationA']
locationB=cgi['locationB']
date0=cgi['date0'].to_f
date1=cgi['date1'].to_f
if (locationA=="" or locationB=="" or date0=="" or date1=="") then
  data = nil
else
  data = count_person_trip(locationA, locationB, date0, date1)
end

output = Hash.new
output["locationA"] = locationA
output["locationB"] = locationB
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

