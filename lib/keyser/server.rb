require "socket"
require "thread"
require_relative "connection"

module Keyser
  class Server
    def initialize(port, app)
      @server = TCPServer.new(port)
      @app = app
    end

    def start
      loop do
        socket = @server.accept
        Thread.new do
          connection = Connection.new(socket, @app)
          connection.process
        end
      end
    end
  end

  class App
    def call(env)
      sleep 5 if env["PATH_INFO"] == "/sleep"
      message = "jaso..."
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
