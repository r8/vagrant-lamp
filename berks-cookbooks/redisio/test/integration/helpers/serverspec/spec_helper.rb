require 'serverspec'

# shared examples
require_relative 'redisio_examples'
require_relative 'sentinel_examples'

set :backend, :exec
