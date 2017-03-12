require "socket"
require "eventmachine"
require_relative "connection"

module Keyser
  class Server
    def initialize(port, app)
      @app = app
      @port = port
    end

    def start
      EM.run do
        EM.start_server "localhost", @port, Connection do |connection|
          connection.app = @app
        end
      end
    end
  end

  class App
    def call(env)
      #sleep 5 if env["PATH_INFO"] == "/sleep"
      message = "aaaaa"
      [
        200,
        { "Content-Type" => "text/plain", "Content-Lenght" => message.size.to_s },
        [message]
      ]
    end
  end

  app = App.new
  server = Server.new(3000, app)
  puts "Kazyer is started!"
  server.start
end
