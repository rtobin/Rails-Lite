module Phase2
  class ControllerBase
    attr_reader :req, :res

    # Setup the controller
    def initialize(req, res)
      # @query = req.query
      # @cookies = req.cookies
      # @body = res.body
      @req = req
      @res = res
      @already_built_response = false
    end

    # Helper method to alias @already_built_response
    def already_built_response?
      @already_built_response
    end

    # Set the response status code and header
    def redirect_to(url)
      raise if already_built_response?
      @res["Location"] = url
      @res.status = 302
      @already_built_response = true

      nil
    end

    # Populate the response with content.
    # Set the response's content type to the given type.
    # Raise an error if the developer tries to double render.
    def render_content(content, content_type)
      raise if already_built_response?
      @res.content_type = content_type
      @res.body = content

      @already_built_response = true

      nil
    end
  end
end
