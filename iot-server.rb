#
# iot-server.rb : IoT Server with REST-API for sensors/actuators
#   v0.1 2015/11 : just storage with REST-API
#
# usage:
#   ruby iot-server.rb
#

require 'webrick'
require 'uri'

require 'optparse'

Version="0.1"

def parse_option()
option={}
OptionParser.new do |opt|
#  opt.on('-a',         '1文字オプション 引数なし')         {|v| option[:a] = v}
  opt.on('-p VALUE',   'port number for REST API')   {|v| option[:port] = v}
#  opt.on('-c [VALUE]', '1文字オプション 引数あり（省略可能）'){|v| option[:c] = v}

  begin  
    opt.parse!(ARGV)
  rescue OptionParser::ParseError => err
    puts err.message
    puts opt.to_s
    exit
  end
end

  return(option)
end

def launch_webrick(documentroot, bindaddress, port)
  opt = { 
    :DocumentRoot   => documentroot,
    :BindAddress    => bindaddress,
    :Port           => port
  }
  server = WEBrick::HTTPServer.new(opt)
  
  ['INT', 'TERM'].each {|signal| 
    trap(signal) {
      server.shutdown
      exit
    }
  }
  return (server)
end
option=parse_option()
port = option[:port]==nil ? 55555 : option[:port]
server = launch_webrick(".", nil, port)
p option
exit
  
require 'json'
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

$st = Storage.new
class ServletAction < WEBrick::HTTPServlet::AbstractServlet
  def do_POST (req, res)
    key = req.path.sub(/^\/iot\//, "")
    $st.put(key, req.body)

    output = req.body
    res.body = output
  end

  def do_GET (req, res)
    key = req.path.sub(/^\/iot\//, "")
    data = $st.get(key)

    res['Content-Type:'] = 'application/json'
    res.body = data.to_json
    p res
  end
end

server.mount('/iot', ServletAction)

# サーバを開始する
server.start
