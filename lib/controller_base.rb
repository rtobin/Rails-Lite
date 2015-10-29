require 'active_support'
require 'active_support/core_ext'
require 'erb'
require 'securerandom'


class ControllerBase
  attr_reader :req, :res, :params

  def initialize(req, res, route_params = {})
    @req = req
    @res = res
    @params = Params.new(req, route_params)
    @already_built_response = false
  end

  def already_built_response?
    @already_built_response
  end

  def auth_token
    if @auth_token.nil?
      @auth_token = SecureRandom.urlsafe_base64
      flash[:security] = @auth_token
    end

    @auth_token
  end

  def form_authenticity_token
    @auth_token
  end

  def protect_from_forgery(options = {})
    # options not implemented
    @authenticity_protected = true
    raise "Forgery!" unless params[:auth_token] && flash["auth_token"] == params[:auth_token]
  end

  # Set the response status code and header
  def redirect_to(url)
    raise if already_built_response?
    @res["Location"] = url
    @res.status = 302
    @already_built_response = true
    @session.store_session(@res)
    flash.store_flash(@res)
    nil
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    cur_path = File.dirname(__FILE__)
    template_direc = File.join(cur_path, "..", "..", "views",
                                self.class.name.underscore)

    template_file = template_direc + "/#{template_name}.html.erb"
    content = ERB.new(File.read(template_file)).result(binding)
    render_content(content, "text/html")
    @session.store_session(@res)
    flash.store_flash(@res)
  end



  def session
    @session || reset_session!
  end

  def flash
    @flash ||= Flash.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    if @authenticity_protected &&
              name == :create || name == :update || name == :destroy
      protect_from_forgery
    end

    self.send(name)
    render(name) unless already_built_response?
    nil
  end
end
