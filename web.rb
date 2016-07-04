require 'json'
require 'redis'
require 'sinatra'
require "sinatra/reloader" if development?

before do
  pass if %w[health].include? request.path_info.split('/')[1]
  halt 401, "Not authorized\n" unless params[:key] == ENV['SECRET_TOKEN']
end

require 'json'
get '/health' do
  logger.info { 'Health check called' }
  %Q'{ "status_code": 0, "pid": #{Process.pid} }'
end

get '/' do
  @channels = ENV['CHANNELS'].delete('#').split(',')
  erb :root
end

get '/:channel' do
  redis = Redis.new(:url => ENV['REDIS_URL'])
  @counts = redis.zrevrange(params[:channel], 0, 19, :with_scores => true)
  erb :index
end