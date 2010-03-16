class Ch2::Requests::DiffDat < Ch2::Requests::Dat

private
  def build_request_headers(headers)
    returning headers = super do
      headers["Range"]             = "bytes=#{size-1}-"
      headers["If-Modified-Since"] = board.written_at.rfc822.to_s
      headers.delete("Accept-Encoding")
    end
  end

  def partial_modified?
    content_length >= 2 && response_body[0,1] == "\n"
  end

  def after_execute
    if partial_response?
      if partial_modified?
        partial_content = response_body[1..-1]
        dat.append_file(partial_content, last_modified)
        updated
      else
        # not modified
        @updated = false
      end
    else
      super
    end
  end
end
