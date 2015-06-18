require 'erb'

class Page
  def initialize(vars)
    @vars = vars
  end

  def render(path)
    content = File.read(File.expand_path(path))
    renderer = ERB.new(content)
    renderer.result(binding)
  end
end
