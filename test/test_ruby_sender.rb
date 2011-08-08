require 'helper'

class TestRubyUdpSender < Test::Unit::TestCase
  context "with ruby sender" do
    setup do
      @addresses = [['localhost', 12201], ['localhost', 12202]]
      @sender = GELF::RubyUdpSender.new(@addresses)
      @datagrams1 = %w(d1 d2 d3)
      @datagrams2 = %w(e1 e2 e3)
    end

    context "send_datagrams" do
      setup do
        @sender.send_datagrams(@datagrams1)
        @sender.send_datagrams(@datagrams2)
      end

      before_should "be called 3 times with 1st and 2nd address" do
        UDPSocket.any_instance.expects(:send).times(3).with do |datagram, _, host, port|
          datagram.start_with?('d') && host == 'localhost' && port == 12201
        end
        UDPSocket.any_instance.expects(:send).times(3).with do |datagram, _, host, port|
          datagram.start_with?('e') && host == 'localhost' && port == 12202
        end
      end
    end
  end
  
  context "with ruby tcp sender" do
    setup do
      @addresses = [['localhost', 12201], ['localhost', 12202]]
      @sender = GELF::RubyTcpSender.new(@addresses)
      @datagrams1 = %w(d1 d2 d3)
      @datagrams2 = %w(e1 e2 e3)
    end

    context "send_datagrams" do
      context "with more than one" do
        should "raise an error" do
          assert_raises(ArgumentError) { @sender.send_datagrams(['a', 'b'])}
        end
      end

      context "with only one" do
        setup do
          @sender.send_datagrams([:datagram])
        end

        before_should "send to the server then close the socket" do
          socket = mock("socket")
          socket.expects(:send).with(:datagram, 0).twice
          socket.expects(:close).twice
          TCPSocket.expects(:new).with('localhost', 12201).returns(socket)
          TCPSocket.expects(:new).with('localhost', 12202).returns(socket)
        end
      end

      context "failing to deliver" do
        setup do
          TCPSocket.expects(:new).raises(ArgumentError)
        end

        should "just return failed" do
          assert_equal :failed, @sender.send_datagrams([:datagram])
        end
      end
    end

     


  end
end
