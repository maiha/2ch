module Ch2::PrettyDebug
private
  def pretty_debug(value, logger = nil, nest = 1)
    klass  = self.class.name
    method = caller[nest].scan(/`(.*)'/)
    value  = value.inspect unless value.is_a?(String)

    logger ||= ActiveRecord::Base.logger
    logger.debug("%s#%s: %s" % [klass, method, value])
  end
end
