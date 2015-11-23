module ApplicationHelper
  def capture_html(&block)
    content = capture(&block) if block_given?
    content.gsub('"', "'") unless content.nil?
  end
end
