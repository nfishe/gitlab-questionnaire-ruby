require 'net/http'
require 'set'
require 'time'

class Metric
  attr_reader :name, :duration, :description

  def initialize(name, duration, description: nil)
    @name        = name
    @duration    = duration
    @description = description
  end

  def to_header
    "#{name}; dur=#{duration.to_d.truncate(2).to_f};"
  end
end

class MetricConverter
  Stats = Struct.new(:total_call_time, :call_count, :latency) do
    def update(call_time)
      self.total_call_time += call_time
      self.call_count += 1
    end
  end

  attr_reader :stats

  def initialize
    @stats = MetricsStats.new
  end

  def update; end
end

def redirected(location)
  warn "redirected to #{location}"
  fetch(location)
end

def fetch(uri_str)
  response = Net::HTTP.get_response(URI(uri_str))
  case response
  when Net::HTTPSuccess
    response
  when Net::HTTPRedirection
    redirected(response['location'])
  else
    response.value
  end
end

if $PROGRAM_NAME == __FILE__
  start_time = Time.now.to_i
  current_time = start_time
  stop_time = start_time + 5 * 60

  converter = MetricConverter.new do
    call_count
  end
  metrics = []
  while current_time < stop_time
    response = fetch('https://gitlab.com')
    begin
      converter.update!
      metric = Metric.new(converter.stats.total_call_time * 1000, { status: response.status })
      metrics.push(metric.to_header)
    rescue StandardError => e
      puts "raised an exception: #{e.message}, #{e.backtrace}"
    end
    current_time = Time.now.to_i
  end

  puts metrics
end
