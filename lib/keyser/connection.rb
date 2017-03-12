require "http/parser"
require "stringio"
require "eventmachine"

module Keyser
  class Connection < EM::Connection
    attr_accessor :app

    def post_init
 		  @parser = Http::Parser.new(self)
    end

    def receive_data(data)
      @parser << data
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

      send_data "HTTP/1.1 #{status} #{response} \r\n"
      send_data "\r\n"

      headers.each_pair do |name, value|
        send_data "#{name}: #{value}"
      end
      send_data "\r\n"

      body.each do |chunk|
        send_data chunk
      end
      body.close if body.respond_to? :close

      close_connection_after_writing
    end

    def close
      @socket.close
    end
  end
end
