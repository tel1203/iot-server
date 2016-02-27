#
# storage.rb : data storage on local FS
#

require 'json'
require 'uri'

class Storage
  def initialize(dir="./data/")
    begin
      File::ftype(dir)
    rescue Errno::ENOENT
      printf("Error: ENOENT: %s\n", dir)
      printf("Create directory: %s\n", dir)
      Dir.mkdir(dir)
    rescue Errno::ENOTDIR
      printf("Error: ENOTDIR: %s\n", dir)
      exit
    end
    @dir=dir

    dir="./data2/"
    begin
      File::ftype(dir)
    rescue Errno::ENOENT
      printf("Error: ENOENT: %s\n", dir)
      printf("Create directory: %s\n", dir)
      Dir.mkdir(dir)
    rescue Errno::ENOTDIR
      printf("Error: ENOTDIR: %s\n", dir)
      exit
    end
    @dir2=dir

    true
  end

  def make_filename(key)
    fname=@dir+"/"+URI.escape(key)

    return (fname)
  end

  def make_filename2(key, time)
    dir=@dir2+"/"+URI.escape(key)
    begin
      File::ftype(dir)
    rescue Errno::ENOENT
      Dir.mkdir(dir)
    end
    fname=dir+"/"+Time.at(time).strftime("%Y%m%d")+".txt"

    return (fname)
  end

  def put(key, value, info=nil)
    data=Hash.new
    data[:receivedAt]=Time.now.to_f
    data[:key]=key
    data[:value]=value
    data[:information]=info

    fname=make_filename(key)
    f=open(fname, "a")
    f.puts(data.to_json)
    f.close()

    return (true)
  end

  def put2(key, time, value)
    fname=make_filename2(key, time)
    f=open(fname, "a")
    f.puts(value.to_json)
    f.close()

    return (true)
  end

  def get2(key, query=nil)
    return (_last_n_records(key, 1)) if (query == nil)
    return (_last_n_records(key, 1)) if (query.size == 0)

    # parse query
    keys=query.keys

    # case: "count"
    if (keys.index("count")) then
      count = query["count"]

      if (count == "") then # count without option
        result = _count_records(key)

        # Making hash variable for output
        # count: number of data
        data_bin = Hash.new
        data_bin["count"]=result

        return (data_bin)
      elsif (count != nil) then # count with number
        return (_last_n_records(key, count.to_i))
      end
    end

    return (nil)
  end


  def _last_n_records(key, n)
    files = _data_files(key)

    index=-1
    outn=0
    records = Array.new
    while (outn < n) do
      fname = files[index]
      records += _get_last_n_records(fname, n-outn)
      outn += records.size

      index -= 1
    end

    return (records)
  end

  def _get_last_n_records(fname, n)
    l = _count_records_file(fname)
    skip = l-n
    f=open(fname, "r")

    # Skip first lines
    i=1
    if (i<skip) then
      while ((line = f.gets) and (i<skip)) do
        i += 1
      end
    end
   
    # Read n lines 
    outn=0
    records = Array.new
    while (line = f.gets) do
      data = JSON.parse(line)
      records.push(data)
      outn += 1
    end

    f.close

    #return (outn) # Return # of read lines
    return (records)
  end

  def _count_records(key)
    files = _data_files(key)

    count = 0
    files.each do |fname|
      count += _count_records_file(fname)
    end
    return (count)
  end

  def _count_records_file(fname)
    l = `wc -l #{fname}`.split(" ")[0].to_i
    return (l)
  end

  def _data_files(key)
    files = Dir.glob(@dir2+"/"+URI.escape(key)+"/*").sort
    return (files)
  end

  ##########
  # For analysis
  def _get_records_period(key, since, till=0) # since, till: unixtime
    files = _data_files(key)

    records = Array.new
    time = since
    i = 0
    while (time < till) do
      time = since+(i*24*60*60)
      begin
        fname = make_filename2(key, time)
        f = open(fname, "r")
        while (line=f.gets) do
          next if (line=="null")
          record = JSON.parse(line)
          data = record["data"]
          data = record["value"]["data"] if (data == nil)

          time = Time.parse(data["created_at"]).to_f
          if (time >= since and time < till) then
            records.push(data)
          end
        end
        i += 1
      rescue Errno::ENOENT
        i += 1
      end
    end
  
    return (records)
  end

  ##########

end

def unixtime(date_iso8601)
  return(Time.parse(date_iso8601).to_f)
end


class Storage2
  def initialize(dir="./data/")
    begin
      File::ftype(dir)
    rescue Errno::ENOENT
      printf("Error: ENOENT: %s\n", dir)
      printf("Create directory: %s\n", dir)
      Dir.mkdir(dir)
    rescue Errno::ENOTDIR
      printf("Error: ENOTDIR: %s\n", dir)
      exit
    end

    @dir=dir

    true
  end

  def make_filename(key)
    fname=@dir+"/"+URI.escape(key)

    return (fname)
  end

  def put(key, value, info=nil)
    data=Hash.new
    data[:receivedAt]=Time.now.to_f
    data[:key]=key
    data[:value]=value
    data[:information]=info

    fname=make_filename(key)
    f=open(fname, "a")
    f.puts(data.to_json)
    f.close()

    return (true)
  end

  def get(key, query=nil)
    fname=make_filename(key)

    data="{}"
    if (query == nil) then
      data = `tail -n 1 #{fname} 2> /dev/null`
      return (nil) if ($? != 0)
    end
    if (query.size == 0) then
      data = `tail -n 1 #{fname} 2> /dev/null`
      return (nil) if ($? != 0)
    end

    # parse query
    keys=query.keys
    if (keys.index("count")) then
      count = query["count"]

      if (count == "") then # count without option
        result = `wc -l #{fname} 2> /dev/null`
        return (nil) if ($? != 0)
        num=result.split(" ")[0].to_i

        # Making hash variable for output
        # count: number of data
        data_bin = Hash.new
        data_bin["value"] = Hash.new
        data_bin["value"]["count"]=num
        data = data_bin.to_json
      elsif (count != nil) then # count with number
        data = `tail -n #{count} #{fname} 2> /dev/null`
        return (nil) if ($? != 0)
      end
    end

    records = Array.new
    data.each_line do |d|
      record = JSON.parse(d)
      records.push(record["value"])
    end
    return (records)
  end
end

