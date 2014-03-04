require 'mock_redis'

Resque.redis = MockRedis.new