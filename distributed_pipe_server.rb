
require_relative 'redis_connector'
# REDIS CONFIGURATION
REDIS_HOST = "127.0.0.1"
REDIS_PORT = "6379"

class DistributedPipeServer

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
        @red.delete_key
        @red.push_key_to_left "start"
        while(@red.left_data == "start") do
            sleep 0.5
        end
            
    end


    def run_input_command
        fork_pid = fork do
            trap("TERM") do
                puts "Signal received, shutting down"
                exit
            end
            begin
                IO.popen(@command,"w")  do |pipe|
                    while(@red.left_data == "stream" || @red.left_data == "ended") do
                        is_stream_ended = @red.left_data
                        data = @red.pop_from_queue
                        if !data.empty?
                            pipe.puts("#{data.join('')}")
                        else
                            sleep 0.2
                        end
                        if is_stream_ended == "ended"
                            break
                        end
                    end
                end
                @red.change_left_data("end")
            rescue Errno::EPIPE
                @red.change_left_data("end")
            rescue Exception => exc
                @red.change_left_data("end")
                puts(exc.message)
            end
            
        end
        trap("SIGINT") do
            puts "sending signal to child"
            Process.kill(:TERM,fork_pid)
        end
        Process.waitpid(fork_pid,0)
    end
end


DistributedPipeServer.new.run_input_command




