class ILI934X
    def initialize(mosi, clk, cs, dc, rst, bl) # add:ILI9342C on M5Stack
      @width = 320
      @height = 240
      @spi = SPI.new(mosi, mosi, clk, cs, dc, rst, bl)
      # return
      if(bl >= 0)
        @bl = GPIO.new(bl, GPIO::OUT)
      end
      init(bl)
    end

    def init(bl)
      @spi.write_command(0xc0)
      @spi.write_data(0x23)

      @spi.write_command(0xc1)
      @spi.write_data(0x10)

      @spi.write_command(0xc5)
      @spi.write_data(0x3e)
      @spi.write_data(0x28)

      @spi.write_command(0xc7)
      @spi.write_data(0x86)

      @spi.write_command(0x36)
      @spi.write_data(0x08)  # Memory Access Control

      @spi.write_command(0x3a)
      @spi.write_data(0x55)  # Pixel Format

      @spi.write_command(0x21)

      @spi.write_command(0xb1)
      @spi.write_data(0x00)
      @spi.write_data(0x18)

      @spi.write_command(0xb6)
      @spi.write_data(0x08)  # Display Function Control
      @spi.write_data(0xa2)
      @spi.write_data(0x27)
      @spi.write_data(0x00)

      @spi.write_command(0x26)
      @spi.write_data(0x01)

      @spi.write_command(0xE0) # Positive Gamma Correction
      @spi.write_data(0x0F)
      @spi.write_data(0x31)
      @spi.write_data(0x2B)
      @spi.write_data(0x0C)
      @spi.write_data(0x0E)
      @spi.write_data(0x08)
      @spi.write_data(0x4E)
      @spi.write_data(0xF1)
      @spi.write_data(0x37)
      @spi.write_data(0x07)
      @spi.write_data(0x10)
      @spi.write_data(0x03)
      @spi.write_data(0x0E)
      @spi.write_data(0x09)
      @spi.write_data(0x00)

      @spi.write_command(0xE1) # Negative Gamma Correction
      @spi.write_data(0x00)
      @spi.write_data(0x0E)
      @spi.write_data(0x14)
      @spi.write_data(0x03)
      @spi.write_data(0x11)
      @spi.write_data(0x07)
      @spi.write_data(0x31)
      @spi.write_data(0xC1)
      @spi.write_data(0x48)
      @spi.write_data(0x08)
      @spi.write_data(0x0F)
      @spi.write_data(0x0C)
      @spi.write_data(0x31)
      @spi.write_data(0x36)
      @spi.write_data(0x0F)

      @spi.write_command(0x11) # Sleep Out
      sleep 0.12

      @spi.write_command(0x29) # Display ON
      if(bl >= 0)
        @bl.write(1)
      end
    end

    def writeChar(char, x, y, height = 7, color = self.color(0, 0, 0), background_color = nil)

      # Generated with TTF2BMH
      # Font MisakiGothic
      # Font Size: 8
      font_width = 3
      font_height = 7
      width = height / 7 * 3
      char_addr =
      {
        32 => [0, 0, 0], 46 => [0,32,0], 48 => [28,42,28], 49 => [36,62,32], 50 => [50,42,36], 51 => [34,42,20], 52 => [24,20,62], 53 => [46,42,18], 54 => [28,42,18], 55 => [2,58,6], 56 => [20,42,20], 57 => [36,42,28], 58 => [0,36,0]
      }
      code = char.ord
      if code >= 32 && code <= 58 
        bitmap = char_addr[code]
      end

      width.times do |dx|
        height.times do |dy|
          i = dx * font_width / width
          j = dy * font_height / height 
          if bitmap[i] & (1 << j) != 0
            drawPixel(x + dx, y + dy, color)
          elsif background_color != nil
            drawPixel(x + dx, y + dy, background_color)
          end
        end
      end
    end

    def writeString(str, x, y, margin_x, margin_y, height = 7, color = self.color(0, 0, 0), background_color = nil)
      home_x = x
      str.each_char do |c|
        if c == "\n"
          x = home_x
          y += margin_y
        else
          writeChar(c, x, y, height, color, background_color)
          x += margin_x
        end
      end
    end

    def drawPixel(x, y, color)
      if x < 0 || x > 320 || y < 0 || y > 240
        return
      end
      set_block(x, x, y, y)
      @spi.write_command(0x2c)
      @spi.write_data_word(color)
    end

    def drawRectangle(x1, x2, y1, y2, color)
      set_block(x1, x2, y1, y2)
      @spi.write_command(0x2c)
      (x2 - x1).times do
        @spi.write_color(color, y2 - y1 + 1)
      end
    end

    def fill(color)
      drawRectangle(0, @width, 0, @height, color)
    end

    def set_block(x1, x2, y1, y2)
      @spi.write_command(0x2a)
      @spi.write_address(x1, x2)
      @spi.write_command(0x2b)
      @spi.write_address(y1, y2)
    end

    def self.color(r, g, b)
      return ((r & 0xf8) << 8) | ((g & 0xfc) << 3) | (b >> 3)
    end
end

# ILI934X Extend Methods(not in class becouse of memory issue)
def drawLine(display, x1, x2, y1, y2, color, weight = 1)
  dx = (x2 - x1).abs
  dy = (y2 - y1).abs

  b = dx < dy 
  if dx < dy
    x1, x2, dx, y1, y2, dy = y1, y2, dy, x1, x2, dx
  end
  x1, x2, y1, y2 = x2, x1, y2, y1 if x2 < x1
  sy = (y2 > y1) ? 1 : -1

  e = -dx
  for x in x1..x2 do
    if !b
      drawPoint(display, x, y1, color, weight)
    else
      drawPoint(display, y1, x, color, weight)
    end
    e += 2 * dy
    if ( e >= 0 )
      y1 += sy
      e -= 2 * dx
    end
  end
end

def drawPoint(display, x, y, color, weight = 1)
  x1 = x - weight / 2
  x2 = x + weight / 2
  y1 = y - weight / 2
  y2 = y + weight / 2
  display.drawRectangle(x1, x2, y1, y2, color)
end