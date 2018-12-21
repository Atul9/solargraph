module Solargraph
  module LanguageServer
    class Host
      class Cataloger
        def initialize host
          @host = host
          @mutex = Mutex.new
          @stopped = true
          @pings = []
        end

        # Notify the Cataloger that changes are pending.
        #
        # @return [void]
        def ping lib
          mutex.synchronize { pings.push lib }
        end

        def synchronizing?
          !pings.empty?
        end

        # Stop the catalog thread.
        #
        # @return [void]
        def stop
          @stopped = true
        end

        # True if the cataloger is stopped.
        #
        # @return [Boolean]
        def stopped?
          @stopped
        end

        # Start the catalog thread.
        #
        # @return [void]
        def start
          return unless stopped?
          @stopped = false
          Thread.new do
            until stopped?
              sleep 0.1
              next if pings.empty?
              mutex.synchronize do
                lib = pings.shift
                next if pings.include?(lib)
                host.catalog lib
              end
            end
          end
        end

        private

        # @return [Host]
        attr_reader :host

        # @return [Mutex]
        attr_reader :mutex

        # @return [Array]
        attr_reader :pings
      end
    end
  end
end
