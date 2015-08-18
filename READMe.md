
### Assumption:
The command which is sending it's output to another command via remote pipe is called as client

The command which is taking input from client is called as server

By default the redis url is hardcoded as 127.0.0.1, can be changed to different url by editing the constants(REDIS_HOST,REDIS_PORT) in files distributed_pipe.rb and distributed_pipe_server.rb

### Internals:-

Using redis queue as a way to communicate between the two process.
First element on the left side of the queue is used for communication, signals being sent between both the process are
1. Start
2. Stream (Input Streaming)
3. Ended (meaning stream is ended)
4. End  (Signal all processes to quit)

And the next elements in the queue are used to send output of the first command, which are poped as they are read. Buffer size of each element is 20 lines.

Max Buffer Limit is 512MB, constraint of redis

Used Ruby's IO Popen to control the streams of stdin and stdout

### Setup:
Run the following commands in order
```
git clone git@github.com:domitian/distributed_pipe.git
cd distributed_pipe
bundle install 
```

Now the app is ready is go

### Usage:
## Server side Running

ruby distributed_pipe_server.rb REDIS_KEY COMMAND_TO_RUN

ex:- 

`ruby distributed_pipe_server.rb cc ls`

## Client Side Running

ruby distributed_pipe.rb REDIS_KEY COMMAND_TO_RUN

ex:-

`ruby distributed_pipe.rb cc wc -l`

### Testing:-

If the redis url is 127.0.0.1, then just open two tabs and go to the app directory in both the tabs and then run the following commands

TERMINAL 1(SERVER)

`ruby distributed_pipe_server.rb cc ls`

TERMINAL 2(CLIENT)

`ruby distributed_pipe.rb cc yes`


### Constraints:-

The server should run before client, else the client will exit with error message saying server command is wrong

