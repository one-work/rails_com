require 'vips'
module BmpUtil
  extend self
  # 从 Vips 直方图计算 Otsu 阈值（纯 Ruby，256次迭代耗时 < 0.05ms）
  def otsu_threshold(hist_bytes)
    total = hist_bytes.sum
    return 128 if total == 0

    sum_i = hist_bytes.each_with_index.sum { |c, i| c * i }
    sum_b = 0.0
    w_b = 0.0
    max_v = 0.0
    thresh = 128

    hist_bytes.each_with_index do |c, i|
      w_b += c
      break if w_b == total
      sum_b += i * c
      w_f = total - w_b
      next if w_f == 0

      m_b = sum_b / w_b
      m_f = (sum_i - sum_b) / w_f
      v = w_b * w_f * (m_b - m_f) ** 2

      if v > max_v
        max_v = v
        thresh = i
      end
    end
    thresh
  end

  # 完整流水线：缩放 → 灰度 → Otsu 二值化 → 打印机位图
  def to_bitmap_bytes(input_path, width_px: 280, invert: true)
    # 1. 先完整加载图片到内存，再高质量缩放到目标宽度并转为灰度。
    #    直接使用 streaming thumbnail 在某些 PNG 文件上会触发 libpng 的 "out of order read" 错误，
    #    因此改为先 new_from_file（完整加载），再按比例缩放（Lanczos3）。
    # 为避免 libpng 的流式读取问题（out of order read），直接完整加载图片到内存再缩放。
    # 这比 streaming thumbnail 占用更多内存，但能保证后续 histogram / write_to_memory 不会触发错误。
    img = Vips::Image.new_from_file(input_path)
    if img.width > width_px
      scale = width_px.to_f / img.width
      img = img.resize(scale, kernel: :lanczos3)
    end

    # 如果可用，尝试自动旋转（某些 vips 绑定提供 autorot/autorotate）
    begin
      if img.respond_to?(:autorot)
        img = img.autorot
      elsif img.respond_to?(:autorotate)
        img = img.autorotate
      end
    rescue => e
      warn "BmpUtil: autorotate failed or unsupported: #{e.message}"
    end

    img = img.colourspace(:b_w)
    # 强制为 8-bit 单通道，保证 write_to_memory 返回 0..255 的字节阵列
    begin
      img = img.cast('uchar')
    rescue => _e
      # 如果 cast 不支持（极少数绑定/格式），继续使用原图，但结果可能不为 8-bit
    end

    # 2. Otsu 自适应阈值：直接从像素字节构建直方图，避免使用 hist_find 导致的类型/打包问题
    pixels_bytes = img.write_to_memory.bytes
    hist = Array.new(256, 0)
    pixels_bytes.each { |b| hist[b] += 1 }
    otsu_thresh = otsu_threshold(hist)
    bin = img >= otsu_thresh
    bin = bin.invert if invert # 热敏纸物理映射：255(黑)→1(打印)，0(白)→0(留白)

    # 3. 逐行位打包（MSB 优先，8 像素对齐）
    pixels = bin.write_to_memory.bytes
    w = img.width
    h = img.height
    row_b = (w + 7) / 8

    bitmap = []
    h.times do |y|
      row_b.times do |bx|
        byte = 0
        8.times do |bit|
          val = pixels[y * w + bx * 8 + bit] || 0
          byte = (byte << 1) | (val > 128 ? 1 : 0)
        end
        bitmap << byte
      end
    end
    [bitmap, row_b, h]
  end
end