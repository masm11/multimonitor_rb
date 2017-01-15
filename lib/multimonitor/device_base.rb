class DeviceBase
  def initialize(width, initial_data)
    @data = Array.new(width, initial_data)
  end
  
  def push_data(new_data)
    @data.rotate!
    @data[@data.length - 1] = new_data
  end
  
  def get_last_data
    @data[@data.length - 1]
  end
  
end
