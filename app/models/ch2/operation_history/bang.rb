class Ch2::OperationHistory::Bang < Ch2::OperationHistory
  class << self
    private
      def execute_arg(image)
        image.is_a?(Ch2::Image) ? image.id : image.to_s
      end
  end

  def rollback(dependent = false)
    image = Ch2::Image.find(arg)
    image.dirty = false
    image.save!
    destroy if dependent
  end
end
