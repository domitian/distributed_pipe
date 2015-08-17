require_relative 'redis_connector'
# REDIS CONFIGURATION
REDIS_HOST = "127.0.0.1"
REDIS_PORT = "6379"

class DistributedPipe

    attr_reader :redis_key
    attr_reader :command_type
    attr_reader :command
    attr_reader :redis
    def initialize
        @red = RedisConnector.new(REDIS_HOST,REDIS_PORT)
        @red.check_if_redis_is_live
        if ARGV.count >= 3
            @redis_key = ARGV.shift
            @command_type = ARGV.shift
            @command = ARGV.join(" ")
        else
            abort "Wrong number of commandline arguments"
        end
        @red.push_key_to_left @redis_key,"output_start"
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
                        puts buffer
                        @red.push_key_to_right @redis_key,buffer.join("\n")
                        buffer = []
                        count = 0
                    end
                end
                unless buffer.empty?
                    puts buffer
                    @red.push_key_to_right  @redis_key,buffer.join("\n")
                end
            end
        end
        trap("SIGINT") do
            puts "sending signal to child"
            Process.kill(:TERM,fork_pid)
        end
        Process.waitpid(fork_pid,0)
    end

end


DistributedPipe.new.run_command




