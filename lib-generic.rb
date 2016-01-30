#
# lib-generic.rb : generic functions for iot-server.rb
#

require 'optparse'
require 'webrick'

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

