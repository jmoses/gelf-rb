module GELF
  # Plain Ruby UDP sender.
  class RubyUdpSender
    attr_accessor :addresses

    def initialize(addresses)
      @addresses = addresses
      @i = 0
      @socket = UDPSocket.open
    end

    def send_datagrams(datagrams)
      host, port = @addresses[@i]
      @i = (@i + 1) % @addresses.length
      datagrams.each do |datagram|
        @socket.send(datagram, 0, host, port)
      end
    end
  end

  class RubyTcpSender
    attr_accessor :addresses

    def initialize(addresses)
      @addresses = addresses
    end

    def send_datagrams( datagrams )
      unless datagrams.size == 1
        raise ArgumentError.new("TCP sending only supports one datagram.")
      end

      @addresses.each do |host, port|
        TCPSocket.open(host, port) do |socket|
          socket.send(datagrams[0], 0)
        end
      end rescue :failed
    end
  end
end
