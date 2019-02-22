module LogHelpers
  def self.create_logger 
    $stdout = IO.new(IO.sysopen('/proc/1/fd/1', 'w'), 'w')
    $stdout.sync = true
    Logger.new($stdout)
  end
end