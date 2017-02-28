require "http/parser"

module Keyser
  class Connection
    def initialize(socket)
      @socket = socket
 		  @parser = Http::Parser.new(self)
    end

    def process
      until @socket.closed? || @socket.eof? do
        data = @socket.readpartial(1024)
        @parser << data
      end
    end

    def on_message_complete
      puts "Method: " + @parser.http_method
      puts "Path: " + @parser.request_path
      puts "Headers: " + @parser.headers.inspect

      send_resoponse
    end

    def send_resoponse
      @socket.write "HTTP/1.1 200 OK \r\n"
      @socket.write "\r\n"
      @socket.write "Keyser Soze is my name!!\n"

      close
    end

    def close
      @socket.close
    end
  end
end
