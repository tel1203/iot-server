#
# storage.rb : data storage on local FS
#

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

