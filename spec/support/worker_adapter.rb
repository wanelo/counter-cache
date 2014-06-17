class TestWorkerAdapter
  def enqueue(delay, base_class, options)
    options[:source_object_class_name] = base_class.constantize
    counter_class = options[:counter].constantize
    counter = counter_class.new(nil, options)
    counter.save!
  end
end
