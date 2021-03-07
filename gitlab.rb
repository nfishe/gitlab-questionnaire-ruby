require 'net/http'
require 'set'
require 'time'

def redirected(location)
    warn "redirected to #{location}"
    fetch(location, limit - 1)

def fetch(uri_str, limit = 10)
    response = Net::HTTP.get_response(URI(uri_str))
    case response
    when Net::HTTPSuccess then response
    when Net::HTTPRedirection then redirected(response['location'])
    else
      response.value
    end
end

if __FILE__ == $0
    start_time = Time.now.to_i
    current_time = start_time
    stop_time = start_time + 5*60

    while current_time < stop_time
        fetch('https://gitlab.com')
        current_time = Time.now.to_i

        puts current_time - Time.now.to_i
    end
end
