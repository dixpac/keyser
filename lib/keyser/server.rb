require "socket"
require "thread"
require_relative "connection"

module Keyser
  class Server
    def initialize(port, app)
      @server = TCPServer.new(port)
      @app = app
    end

    def prefork(workers)
      workers.times do
        fork do
          puts "Forked #{Process.pid}"
          start
        end
      end
      Process.waitall
    end

    def start
      loop do
        socket = @server.accept
        connection = Connection.new(socket, @app)
        connection.process
      end
    end
  end

  class App
    def call(env)
      sleep 5 if env["PATH_INFO"] == "/sleep"
      message = "called from #{Process.pid}"
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
  server.prefork(3)
end
