require_relative 'redis_connector'
# REDIS CONFIGURATION
REDIS_HOST = "127.0.0.1"
REDIS_PORT = "6379"

class DistributedPipeClient

    attr_reader :command
    attr_reader :redis
    def initialize
        if ARGV.count >= 2
            redis_key = ARGV.shift
            @command = ARGV.join(" ")
            @red = RedisConnector.new(REDIS_HOST,REDIS_PORT,redis_key)
            @red.check_if_redis_is_live
        else
            abort "Wrong number of commandline arguments"
        end
        while(@red.left_data != "start") do

            sleep 0.5
            puts "waiting for the server command"
            if @red.left_data == "end"
                abort "server command doesn't exist"
            end
        end
        @red.change_left_data("stream")
    end



    def run_command
        fork_pid = fork do
            trap("TERM") do
                puts "Signal received, shutting down"
                exit
            end
            IO.popen(@command) do |f|
                buffer = []
                count = 0
                f.each do |line|
                    buffer << line
                    count = count + 1
                    if count > 10
                        @red.push_key_to_right buffer.join("")
                        buffer = []
                        count = 0
                    end
                end
                unless buffer.empty?
                    @red.push_key_to_right  buffer.join("")
                end
            end
            @red.change_left_data("ended")
        end
        trap("SIGINT") do
            puts "sending signal to child"
            Process.kill(:TERM,fork_pid)
        end
        Process.waitpid(fork_pid,0)
    end

end


DistributedPipeClient.new.run_command




