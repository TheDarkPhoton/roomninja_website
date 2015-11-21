class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  include SessionsHelper

  def parse_date_params(params, label)
    begin
      year = params[(label.to_s + '(1i)').to_sym].to_i
      month = params[(label.to_s + '(2i)').to_sym].to_i
      day = params[(label.to_s + '(3i)').to_sym].to_i
      return Time.now.change(year: year, month: month, day: day).to_date
    rescue => e
      return nil
    end
  end

  def parse_time_params(params, label)
    begin
      hour = (params[(label.to_s + '(4i)').to_sym] || 0).to_i
      minute = (params[(label.to_s + '(5i)').to_sym] || 0).to_i
      second = (params[(label.to_s + '(6i)').to_sym] || 0).to_i
      return Time.now.change(hours: hour, minutes: minute, seconds: second)
    rescue => e
      return nil
    end
  end

  def parse_datetime_params(params, label)
    begin
      year = params[(label.to_s + '(1i)').to_sym].to_i
      month = params[(label.to_s + '(2i)').to_sym].to_i
      day = params[(label.to_s + '(3i)').to_sym].to_i
      hour = (params[(label.to_s + '(4i)').to_sym] || 0).to_i
      minute = (params[(label.to_s + '(5i)').to_sym] || 0).to_i
      second = (params[(label.to_s + '(6i)').to_sym] || 0).to_i
      return DateTime.parse("#{year}-#{month}-#{day}T#{hour}:#{minute}:#{second}")
    rescue => e
      return nil
    end
  end
end
