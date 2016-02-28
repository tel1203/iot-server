#!/home/ylab/.rbenv/shims/ruby

##!/bin/sh
#    if [ -z $HOME ];then HOME=/Users/tel; export HOME; fi
#    PATH=$HOME/.rbenv/shims:/usr/local/bin:/usr/bin:/bin:$PATH; export PATH
#    exec ruby -S -x $0 "$@"
##! ruby

#
# make_analyse_count_uniqperson.rb : make unique person number in every hours at the day
#
# Usage:
#   ruby make_analyse_count_uniqperson.rb unixtime0 unixtime1 period(min)
#   ruby make_analyse_count_uniqperson.rb wifi_node1 1453129200 1453172500 60 | less
#   ruby make_analyse_count_uniqperson.rb wifi_person_finder_gfo01 1446562800 1455375600 1440 | less
#
# Output: Array of count data, time ordered in ascending order (01:00, 02:00, ... 23:00, 24:00)
#   [
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}
#   ]
#

require 'json'
require 'time'
require './storage.rb'


# $ make_analyse_count_uniqperson.rb 
# $ date -d '2007/2/5 01:02:03' +'%s'
# ylab@okamoto:~/iot-server$ date -d '2016/01/19 00:00:00' +'%s'
# 1453129200
# ylab@okamoto:~/iot-server$ date -d '2016/01/20 00:00:00' +'%s'
# 1453215600

def parse_line(line)
  record = JSON.parse(line)
  data = record["value"]["data"]
  date = Time.parse(data["created_at"]).to_i
  return ([date, data])
end

location = ARGV[0]
date_begin = ARGV[1].to_i
date_end   = ARGV[2].to_i
sec = ARGV[3].to_i*60

storage = Storage.new
fname = storage.make_filename(location)

#
f = open(fname, "r")

output = Array.new
begin
  while (line=f.gets) do
    date, data = parse_line(line)

    # Ener main process
    if (date > date_begin) then
      # initilize variables for counting
      prev_timeslot = timeslot = date/sec # current time slot
      prev_date = date
      macaddrs = Array.new
      record = Hash.new

      begin
        date, data = parse_line(line)
        next if (date < prev_date)
        timeslot = date/sec # current time slot

        if (date >= date_end) then # break if time is passed the end time
          exit
        end
        if (timeslot != prev_timeslot) then
          # Make record
          date0 = timeslot*sec
          date1 = (timeslot+1)*sec
          record = Hash.new
          record["location"] = location
          record["date0"] = date0
          record["date1"] = date1
          record["since"] = Time.at(date0).iso8601
          record["until"] = Time.at(date1).iso8601
          record["count"] = macaddrs.uniq.size
          output.push(record)
p record
          macaddrs = Array.new
          record = Hash.new
        end

        # Processing for each line
#        p data["created_at"]
#        p data
        macaddrs.push(data["hashed_macaddress"])

        prev_timeslot = timeslot
        prev_date = date
#   [
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}.
#     {"location":"wifi_node1","date0":1438506060,"date1":1438592460,"since":"2015-08-02T18:01:00+09:00","until":"2015-08-03T18:01:00+09:00","count":0}
#   ]


      end while (line=f.gets)
    end

  end
rescue Errno::ENOENT
end

f.close()
exit


