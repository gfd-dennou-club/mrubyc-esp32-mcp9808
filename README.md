# mrubyc-gem-mcp9808
mruby/c sources for mcp9808

## device
https://jp.seeedstudio.com/Grove-I2C-High-Accuracy-Temperature-Sensor-MCP9808.html

### data sheet
https://files.seeedstudio.com/wiki/Grove-I2C_High_Accuracy_Temperature_Sensor-MCP9808/res/MCP9808_datasheet.pdf

## sample code

```ruby
i2c = I2C.new(22, 21)
mcp9808 = MCP9808.new(i2c)

if !mcp9808.begin
  puts "Couldn't find MCP9808! Check your connections and verify the address is correct."
else
  puts "Found MCP9808!"
  mcp9808.set_resolution(3)
  # Mode Resolution SampleTime
  #    3  0.0625 ℃       250ms
  puts "wake up MCP9808.... "
  mcp9808.wake()

  loop do
    puts "#{mcp9808.read_temp_c} *C"
    sleep 1
  end
end
```
