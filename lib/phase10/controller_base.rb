require_relative '../phase9/controller_base'
require 'securerandom'

module Phase10
  class ControllerBase < Phase9::ControllerBase

    def protect_from_forgery(options = {})
      # options not implemented
      session["_csrf_token"] = SecureRandom.url_safe.base64(16)
      session.store_session(@res)

      self.define_method(form_authenticity_token) do
        session["_csrf_token"]
      end

      @protect_against_forgery = true
    end



    def redirect_to(url)
      super(url)
      session.store_session(@res)
    end

    def render_content(content, content_type)
      super(content, content_type)
      session.store_session(@res)
    end

    # method exposing a `Session` object
    def session
      @session ||= Session.new(@req)
    end
  end
end
