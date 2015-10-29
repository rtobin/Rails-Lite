require 'json'
require 'webrick'

class Flash
  # find the flash cookie(s) for this app
  # deserialize the cookie into a hash

  def initialize(req)
    flash_cookie = req.cookies.find { |cookie| cookie.name == "_rails_lite_flash" }
    @stuff = {}
    @stuff_now = {}
    JSON.parse(cookie.value).each { |key, val| @stuff_now[key.to_s] = val } if flash_cookie
  end

  def [](key)
    key_str = key.to_s
    @stuff_now[key_str] ? @stuff_now[key_str] : @stuff[key_str]
  end

  def []=(key, val)
    key_str = key.to_s
    @stuff[key_str] = val
    @stuff_now[key_str]
  end

  def now
    @stuff_now
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
     cookie = WEBrick::Cookie.new("_rails_lite_flash", @stuff.to_json)
     cookie.path = "/"
     res.cookies << cookie
  end
end
