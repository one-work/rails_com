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
  def to_bitmap_bytes(input_path, width_px: 384, invert: true)
    # 1. 高质量缩放 + 灰度（自动 EXIF/ICC/线性光/Lanczos3）
    img = Vips::Image.thumbnail(input_path, width_px, size: :down, kernel: :lanczos3).colourspace(:b_w)

    # 2. Otsu 自适应阈值（热敏打印对纸张底色/光照极其敏感，此步大幅提升清晰度）
    otsu_thresh = otsu_threshold(img.hist_find.write_to_memory.bytes)
    bin = img.threshold(otsu_thresh)
    bin = bin.invert if invert # 热敏纸物理映射：255(黑)→1(打印)，0(白)→0(留白)

    # 3. 逐行位打包（MSB 优先，8 像素对齐）
    pixels = bin.write_to_memory.bytes
    w, h = img.width, img.height
    row_b = (w + 7) / 8

    bitmap = ''
    h.times do |y|
      row_b.times do |bx|
        byte = 0
        8.times do |bit|
          val = pixels[y * w + bx * 8 + bit] || 0
          byte = (byte << 1) | (val > 128 ? 1 : 0)
        end
        bitmap << byte.chr
      end
    end
    bitmap
  end
end