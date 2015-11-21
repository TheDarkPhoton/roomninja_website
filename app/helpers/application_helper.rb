module ApplicationHelper
  def capture_html(&block)
    capture(&block).gsub('"', "'") if block_given?
  end
end
