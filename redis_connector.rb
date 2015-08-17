require "redis"



# REDIS CONFIGURATION
REDIS_HOST = "127.0.0.1"
REDIS_PORT = "6379"

REDIS_KEY = "CT"


class RedisConnector
    attr_accessor :redis
    attr_accessor :redis_key
    def initialize(host,port,key)
        @redis = Redis.new(:host => host, :port => port, :db => 15)
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

    def store_in_redis_queue key,val
        @redis.hset @redis_key,key,val
        puts "stored in redis hash"
    end

end

red = RedisConnector.new(REDIS_HOST,REDIS_PORT,REDIS_KEY)
red.check_if_redis_is_live
