#
# storager.rb : 
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

  def get(key, count=1)
    fname=make_filename(key)

    data = `tail -n #{count} #{fname} 2> /dev/null`
    return (nil) if ($? != 0)
    output = JSON.parse(data)

    return (output)
  end
end

