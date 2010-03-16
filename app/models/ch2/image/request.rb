class Ch2::Image::Request < Ch2::Image
  def command
    safe_url = url.delete(%{'"\\}) # "'
    "wget -O - -q -t 2 --timeout=60 '%s' > %s" % [safe_url, path]
  end

  def execute
    logger.debug "#{self.class.name}: #{command}"
    system(command)
  end

  def execute!(recorder = nil)
    execute

    if recorder
      recorder.record{retype!}
    else
      retype!
    end
  rescue => err
    if recorder
      recorder.record{become! :error}
    else
      become! :error
    end

    message = "Fetch Image Error: [%s] %s" % [err.class, err.message]
    logger.error message
  end
end
