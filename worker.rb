require 'cinch'
require 'redis'

def parseMessage(redis, channel, message)
  message.split(' ').uniq.each do |word|
    if redis.zrank(channel, word).is_a? Numeric
      redis.zincrby channel, 1, word
    else
      redis.zadd channel, 1, word
    end
  end
end

bot = Cinch::Bot.new do
  configure do |c|
    c.server   = "irc.chat.twitch.tv"
    c.nick     = ENV['USERNAME']
    c.password = ENV['PASSWORD']
    c.port     = 6667
    c.channels = ENV['CHANNELS'].split(',')
  end

  redis = Redis.new(:url => ENV['REDIS_URL'])

  on :channel do |m|
    parseMessage(redis, m.channel.name[1..-1], m.message)
  end

end

bot.start
