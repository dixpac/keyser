require "http/parser"
require "stringio"

module Keyser
  class Connection
    def initialize(socket, app)
      @socket = socket
      @app = app
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

      env = {}

      @parser.headers.each_pair do |name, value|
        # User-Agent => HTTP_USER_AGENT
        name = "HTTP_" + name.upcase.tr("-", "_")
        env[name] = value
      end
      env["PATH_INFO"] = @parser.request_path
      env["REQUEST_METHOD"] = @parser.http_method
      env["rack.input"] = StringIO.new

      send_resoponse env
    end

    RESPONSES = {
      200 => "OK",
      404 => "Not Found"
    }

    def send_resoponse(env)
      status, headers, body = @app.call(env)
      response = RESPONSES[status]

      @socket.write "HTTP/1.1 #{status} #{response} \r\n"
      @socket.write "\r\n"

      headers.each_pair do |name, value|
        @socket.write "#{name}: #{value}"
      end
      @socket.write "\r\n"

      body.each do |chunk|
        @socket.write chunk
      end
      body.close if body.respond_to? :close

      close
    end

    def close
      @socket.close
    end
  end
end
