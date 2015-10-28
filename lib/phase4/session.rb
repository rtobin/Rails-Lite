require 'json'
require 'webrick'

module Phase4
  class Session
    # find the cookie for this app
    # deserialize the cookie into a hash
    def initialize(req)
      sesh_cookie = req.cookies.find { |x| x.name == "_rails_lite_app" }
      @stuff = sesh_cookie.nil? ? {} : JSON.parse(sesh_cookie.value)
    end

    def [](key)
      @stuff[key.to_s]
    end

    def []=(key, val)
      @stuff[key.to_s] = val
    end

    # serialize the hash into json and save in a cookie
    # add to the responses cookies
    def store_session(res)
      res.cookies << WEBrick::Cookie.new("_rails_lite_app", @stuff.to_json)
    end
  end
end
