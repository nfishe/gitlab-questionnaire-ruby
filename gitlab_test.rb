#!/usr/bin/env ruby

require 'net/http'

def redirected(location)
  # warn "redirected to #{location}"
  fetcher(location)
end

def fetcher(uri_str)
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

def now
  Process.clock_gettime(Process::CLOCK_MONOTONIC, :nanosecond)
end

class Timer
  attr_accessor :nanoseconds, :calls

  def initialize(start)
    @nanoseconds = 0
    @calls = 0
    @start = start
  end

  def seconds
    @nanoseconds / (10**9)
  end

  def fetch(current_time)
    response = fetcher('https://gitlab.com')
    elapsed = now - current_time
    time = Time.at(0, elapsed, :nsec).nsec
    duration = time.to_f.truncate(2).to_i
    puts "dur=#{duration} ns; status=#{response.class.name};"

    duration
  end

  def run
    # Maybe interval?
    start_time = now
    current_time = start_time
    while current_time < start_time + @start * (10**9)
      ns = fetch(current_time)
      @nanoseconds += ns if ns
      @calls += 1
      current_time = now
    end
  end
end

def timer(start)
  t = Timer.new(start)
  t.run

  puts "elapsed=#{t.nanoseconds}/#{t.seconds} ns/s, calls=#{t.calls}"
end

timer 60 * 5 if $PROGRAM_NAME == __FILE__
