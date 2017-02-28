require "socket"
require_relative "connection"

module Keyser
  class Server
    def initialize(port)
      @server = TCPServer.new(port)
    end

    def start
      loop do
        @socket = @server.accept
        connection = Connection.new(@socket)
        connection.process
      end
    end
  end

  server = Server.new(3000)
  puts "Kazyer is started!"
  server.start
end
