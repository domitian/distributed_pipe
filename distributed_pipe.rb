require_relative 'redis_connector'
class DistributedPipe

end


fork_pid = fork do
    trap("TERM") do
        puts "Signal received, shutting down"
        exit
    end
    system("ls")
end

begin
    if ARGV.count >= 3
        redis_key = ARGV.shift
        type = ARGV.shift
        command_to_run = ARGV.join(" ")
        puts "running command #{command_to_run}"
    else
        raise
    end
rescue SystemExit,Interrupt
    Process.kill(0, fork_pid)
    raise
rescue Exception => e
    puts e.message
    begin
        Process.kill(:TERM,fork_pid)
    rescue Errno::ESRCH
        return false
    rescue Errno::EPERM 
        return true
    end
    abort "wrong number of commandline arguments"
end



