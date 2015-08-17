require "redis"






class RedisConnector
    attr_accessor :redis
    def initialize(host,port)
        @redis = Redis.new(:host => REDIS_HOST, :port => REDIS_PORT, :db => 15)
    end

    def check_if_redis_is_live

        begin
           @redis.ping
        rescue Exception => e
            puts e.message
            abort("Redis is down, can't run any commands now")
        end
    end

    def push_key_to_left key,val
        @redis.lpush key,val
    end

    def push_key_to_right key,val
        @redis.rpush key,val
        puts "stored in redis queue"
    end

end

