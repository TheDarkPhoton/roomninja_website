class Numeric
  def to_time_string
    days = self / 1.day
    timeleft = self % 1.day

    hours = timeleft / 1.hour
    timeleft = timeleft % 1.hour

    minutes = timeleft / 1.minute
    seconds = timeleft % 1.minute

    result = ''
    if days > 0
      result += "#{days} " + 'day'.pluralize(days)
    end

    if hours > 0
      result += ' ' if days > 0
      result += "#{hours} " + 'hour'.pluralize(hours)
    end

    if minutes > 0
      result += ' ' if days > 0 || hours > 0
      result += "#{minutes} " + 'minute'.pluralize(minutes)
    end

    if result == '' || seconds > 0
      result += ' ' if days > 0 || hours > 0 || minutes > 0
      result += "#{seconds} " + 'second'.pluralize(seconds)
    end

    result
  end
end