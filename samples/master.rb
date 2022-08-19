# coding: utf-8
i2c = I2C.new(22, 21)
mcp9808 = MCP9808.new(i2c)

if !mcp9808.begin
  puts "Couldn't find MCP9808! Check your connections and verify the address is correct."
else
  puts "Found MCP9808!"
  mcp9808.set_resolution(3)
  # Mode Resolution SampleTime
  #    0     0.5 ℃        30ms
  #    1    0.25 ℃        65ms
  #    2   0.125 ℃       130ms
  #    3  0.0625 ℃       250ms
  while true do
    puts "wake up MCP9808.... "
    mcp9808.wake()

    puts "Resolution in mode: #{mcp9808.get_resolution}"
    temp = mcp9808.read_temp_c
    puts "#{mcp9808.read_temp_c} *C"
    puts "#{mcp9808.read_temp_f} *F"
    sleep 2
    puts "Shutdown MCP9808.... "
    mcp9808.shutdown
    sleep 0.2
  end
end
