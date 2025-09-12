# 此模块专为页模式设计，暂不考虑标准模式
class BaseEsc
  # Printer hardware
  HW_SELECT = [ 0x1b, 0x3d, 0x01 ] # Printer select
  HW_RESET = [ 0x1b, 0x3f, 0x0a, 0x00 ] # Reset printer hardware

  # Feed control sequences
  CTL_LF = [ 0x0a ]                   # Print and line feed
  CTL_FF = [ 0x0c ]                   # Form feed
  CTL_CR = [ 0x0d ]                   # Carriage return
  CTL_HT = [ 0x09 ]                   # Horizontal tab
  CTL_VT = [ 0x0b ]                   # Vertical tab

  # Paper
  PAPER_FULL_CUT = [ 0x1d, 0x56, 0x00 ]			   # 全切纸
  PAPER_PARTIAL_CUT = [ 0x1d, 0x56, 0x01 ]			   # 半切纸（中间还有部分相连）
  PAPER_CUT_A = [ 0x1d, 0x56, 0x41 ]			   # Paper cut A
  PAPER_CUT_B = [ 0x1d, 0x56, 0x42 ]			   # Paper cut B

  # Cash Drawer
  CD_KICK_2 = [ 0x1b, 0x70, 0x00 ]			   # Send pulse to pin 2
  CD_KICK_5 = [ 0x1b, 0x70, 0x01 ]			   # Send pulse to pin 5

  # Code Pages
  CP_SET = [ 0x1b, 0x74 ]	      		   # Set Code Page

  # Text formating
  TXT_NORMAL = [ 0x1b, 0x21, 0x00 ]        # Normal text
  TXT_2HEIGHT = [ 0x1b, 0x21, 0x10 ]        # Double height text
  TXT_2WIDTH = [ 0x1b, 0x21, 0x20 ]        # Double width text
  TXT_UNDERL_OFF = [ 0x1b, 0x2d, 0x00 ]        # Underline font OFF
  TXT_UNDERL_ON = [ 0x1b, 0x2d, 0x01 ]        # Underline font 1
  TXT_UNDERL2_ON = [ 0x1b, 0x2d, 0x02 ]        # Underline font 2
  TXT_BOLD_OFF = [ 0x1b, 0x45, 0x00 ]        # Bold font OFF
  TXT_BOLD_ON = [ 0x1b, 0x45, 0x01 ]        # Bold font ON
  TXT_FONT_A = [ 0x1b, 0x4d, 0x00 ]        # Font type A
  TXT_FONT_B = [ 0x1b, 0x4d, 0x01 ]        # Font type B
  TXT_ALIGN_LT = [ 0x1b, 0x61, 0x00 ]        # 左对齐
  TXT_ALIGN_CT = [ 0x1b, 0x24, 0x80, 0x00 ]        # 居中对齐
  TXT_ALIGN_RT = [ 0x1b, 0x61, 0x02 ]        # 右对齐
  TXT_INVERT_ON = [ 0x1d, 0x42, 0x01 ]        # Inverted color text
  TXT_INVERT_OFF = [ 0x1d, 0x42, 0x00 ]        # Inverted color text
  TXT_COLOR_BLACK = [ 0x1b, 0x72, 0x00 ]        # Default Color
  TXT_COLOR_RED = [ 0x1b, 0x72, 0x01 ]        # Alternative Color (Usually Red)

  # Barcodes
  BARCODE_TXT_OFF = [ 0x1d, 0x48, 0x00 ]         # HRI barcode chars OFF
  BARCODE_TXT_ABV = [ 0x1d, 0x48, 0x01 ]         # HRI barcode chars above
  BARCODE_TXT_BLW = [ 0x1d, 0x48, 0x02 ]         # HRI barcode chars below
  BARCODE_TXT_BTH = [ 0x1d, 0x48, 0x03 ]         # HRI barcode chars both above and below
  BARCODE_FONT_A = [ 0x1d, 0x66, 0x00 ]         # Font type A for HRI barcode chars
  BARCODE_FONT_B = [ 0x1d, 0x66, 0x01 ]         # Font type B for HRI barcode chars
  BARCODE_HEIGHT = [ 0x1d, 0x68 ]               # Barcode Height (1 - 255)
  BARCODE_WIDTH = [ 0x1d, 0x77 ]               # Barcode Width (2 - 6)
  BARCODE_UPC_A = [ 0x1d, 0x6b, 0x00 ]         # Barcode type UPC-A
  BARCODE_UPC_E = [ 0x1d, 0x6b, 0x01 ]         # Barcode type UPC-E
  BARCODE_EAN13 = [ 0x1d, 0x6b, 0x02 ]         # Barcode type EAN13
  BARCODE_EAN8 = [ 0x1d, 0x6b, 0x03 ]         # Barcode type EAN8
  BARCODE_CODE39 = [ 0x1d, 0x6b, 0x04 ]         # Barcode type CODE39
  BARCODE_ITF = [ 0x1d, 0x6b, 0x05 ]         # Barcode type ITF
  BARCODE_NW7 = [ 0x1d, 0x6b, 0x06 ]         # Barcode type NW7

  attr_reader :data
  def initialize
    @data = []
    @data.push(0x1b, 0x40)  # 初始化打印机：清除打印缓存，各参数恢复默认值
    @data.push(0x1b, 0x4c) # 页模式
    @data.push(0x1d, 0x4c, 0x12, 0x00)  # 设置左限（左边距）：向右移动 18（0x12）点
    @data.push(0x1c, 0x26) # 启用 16×16 点阵中文打印模式
    @data.push(0x1c, 0x21, 0x00)  # 中文字间距为 0 点
    @data.push(0x1b, 0x39, 0x06)  # 选择字符编码类型
  end

  def partial_cut!
    @data.concat(PAPER_PARTIAL_CUT)
  end

  def cut!
    @data.concat(PAPER_FULL_CUT)
  end

  def break_line
    @data.concat(CTL_LF)
  end

  def render
    @data.push(*(CTL_LF * 5))
    cut!
  end

  def render_raw
    @data.map {|i| i.to_s(16).rjust(2, '0') }.join('')
  end

  def render_0x
    @data.pack('C*')
  end

  def text(data)
    @data.push *TXT_NORMAL
    @data.push *data.encode('gb18030').bytes
    @data.push *TXT_NORMAL
    @data.push *CTL_LF
  end

  def double_height(data)
    @data.concat *[TXT_2HEIGHT, data.bytes, TXT_NORMAL]
  end

  def text_big(data)
    @data.push 0x1b, 0x21, 0x30 # Quad area text
    @data.push *data.encode('gb18030').bytes
    @data.push *TXT_NORMAL
    @data.push *CTL_LF
  end

  def double_width(data)
    @data.concat *[TXT_2WIDTH, data.bytes, TXT_NORMAL]
  end

  def underline(data)
    @data.concat *[TXT_UNDERL_ON, data.bytes, TXT_UNDERL_OFF]
  end

  def underline2(data)
    @data.concat *[TXT_UNDERL2_ON, data.bytes, TXT_UNDERL_OFF]
  end

  def bold(data)
    @data.concat *[TXT_BOLD_ON, data.bytes, TXT_BOLD_OFF]
  end

  def left(data = '')
    @data.concat *[TXT_ALIGN_LT, data.bytes, TXT_ALIGN_LT]
  end

  def right(data = '')
    @data.concat *[TXT_ALIGN_RT, data.bytes, TXT_ALIGN_LT]
  end

  def center(data = '')
    @data.concat *[TXT_ALIGN_CT, data.encode('gb18030').bytes, TXT_ALIGN_LT]
  end

  def inverted(data)
    @data.concat *[TXT_INVERT_ON, data.bytes, TXT_INVERT_OFF]
  end

  def black
    @data.concat *[TXT_COLOR_BLACK, data.bytes, TXT_COLOR_BLACK]
  end

  def red
    @data.concat *[TXT_COLOR_BLACK, data.bytes, TXT_COLOR_RED]
  end

  def qrcode(data, y: nil)
    bytes = data.bytes
    #qr_type = [0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x41, 0x03] # 模块类型
    qr_size = [0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x43, 0x06] # 设置二维码模块大小
    qr_err = [0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x45, 0x30] # 错误校正水平
    qr_data = [0x1d, 0x28, 0x6b, bytes.size + 3, 0x00, 0x31, 0x50, 0x30] # 设置 QR 码数据
    qr_run = [0x1d, 0x28, 0x6b, 0x03, 0x00, 0x31, 0x51, 0x30] # 打印 Qr 码

    @data.concat *[
      qr_size,
      qr_err,
      qr_data,
      bytes,
      qr_run
    ]
    @data.concat(CTL_LF * 2)
  end

  def barcode(data, opts = {})
    text_position = opts.fetch(:text_position, BARCODE_TXT_OFF)
    possible_text_positions = [
      BARCODE_TXT_OFF,
      BARCODE_TXT_ABV,
      BARCODE_TXT_BLW,
      BARCODE_TXT_BTH
    ]
    unless possible_text_positions.include?(text_position)
      raise ArgumentError("Wrong text position.")
    end
    height = opts.fetch(:height, 50)
    if height && (height < 1 || height > 255)
      raise ArgumentError("Height must be in range from 1 to 255.")
    end
    width = opts.fetch(:width, 3)
    if width && (width < 2 || width > 6)
      raise ArgumentError("Width must be in range from 2 to 6.")
    end

    @data.concat *[
      text_position,
      BARCODE_WIDTH,
      [width],
      BARCODE_HEIGHT,
      [height],
      opts.fetch(:format, BARCODE_EAN13),
      data.bytes
    ]
  end

  def partial_cut
    @data.concat(PAPER_PARTIAL_CUT)
  end

  def cut
    @data.push(0x1d, 0x56, 0x00)  # 全切纸
  end

end
