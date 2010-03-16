Ch2::Message = Struct.new(:name, :email, :created_at, :message)
class Ch2::Message
  def time
    Time.mktime(*ParseDate.parsedate(created_at)[0,6])
  rescue
    nil
  end

  def sender
    created_at.to_s[-1,1]
  end

  def p?
    sender == "P"
  end

  def q?
    sender == "Q"
  end

  def keitai?
    sender == "O"
  end
end
