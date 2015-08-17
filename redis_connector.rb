require "redis"

class RedisConnector
    attr_accessor :redis
    attr_accessor :redis_key
    def initialize(host,port,key)
        @redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => 15)
        @redis_key = key
    end

    def check_if_redis_is_live

        begin
           @redis.ping
        rescue Exception => e
            puts e.message
            abort("Redis is down, can't run any commands now")
        end
    end

    def push_key_to_left val
        @redis.lpush @redis_key,val
    end

    def delete_key 
        @redis.del @redis_key
    end

    def left_data
        return @redis.lindex @redis_key,0
    end

    def push_key_to_right val
        @redis.rpush @redis_key,val
        if left_data == "end"
            abort "quitting because server program quit"
        end
    end


    def change_left_data msg
        @redis.pipelined do
            @redis.lpop @redis_key
            @redis.lpush @redis_key,msg
        end
    end

    def pop_from_queue
        data = [] 
        data = @redis.lrange @redis_key,1,-1
        @redis.ltrim @redis_key,0,1
        data
    end


end

