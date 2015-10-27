require_relative '../phase2/controller_base'
require 'active_support'
require 'active_support/core_ext'
require 'erb'

module Phase3
  class ControllerBase < Phase2::ControllerBase
    # use ERB and binding to evaluate templates
    # pass the rendered html to render_content
    def render(template_name)
      cur_path = File.dirname(__FILE__)
      template_direc = File.join(cur_path, "..", "..", "views",
                                  self.class.name.underscore)

      template_file = template_direc + "/#{template_name}.html.erb"
      content = ERB.new(File.read(template_file)).result(binding)
      render_content(content, "text/html")
    end
  end
end
