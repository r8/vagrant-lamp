# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt


class PoiseArchive::Bzip2::Decompressor

  include PoiseArchive::Bzip2::Constants

  def initialize(io)
    @buff = 0
    @bytes_read = 0
    @computed_combined_crc = 0
    @crc = PoiseArchive::Bzip2::CRC.new
    @current_char = -1
    @io = io
    @live = 0
    @stored_combined_crc = 0
    @su_t_pos = 0
    init
  end

  def count(read)
    @bytes_read += read if read != -1
  end

  # ADDED METHODS
  def pos
    @bytes_read
  end

  def eof?
    @current_state == EOF
  end
  # /ADDED METHODS

  def read(length = nil)
    raise 'stream closed' if @io.nil?

    if length == 1
      r = read0
      count (r < 0 ? -1 : 1)
      r
    else
      r = ''
      if length == nil
        while true do
          b = read0
          break if b < 0
          r << b.chr
        end
        count r.size # ADDED LINE
      elsif length > 0
        length.times do
          b = read0
          break if b < 0
          r << b.chr
        end
        count r.size
      end
      r
    end
  end

  def read0
    ret_char = @current_char

    if @current_state == RAND_PART_B_STATE
      setup_rand_part_b
    elsif @current_state == NO_RAND_PART_B_STATE
      setup_no_rand_part_b
    elsif @current_state == RAND_PART_C_STATE
      setup_rand_part_c
    elsif @current_state == NO_RAND_PART_C_STATE
      setup_no_rand_part_c
    elsif @current_state == EOF
      return -1
    else
      raise 'illegal state'
    end

    ret_char
  end

  def make_maps
    in_use = @data.in_use
    seq_to_unseq = @data.seq_to_unseq

    n_in_use_shadow = 0

    256.times do |i|
      if in_use[i]
        seq_to_unseq[n_in_use_shadow] = i
        n_in_use_shadow += 1
      end
    end

    @n_in_use = n_in_use_shadow
  end

  def init
    check_magic

    block_size = @io.read(1).to_i
    raise 'Illegal block size.' if block_size < 1 || block_size > 9
    @block_size = block_size

    init_block
    setup_block
  end

  def check_magic
    raise 'Magic number does not match "BZh".' unless @io.read(3) == 'BZh'
  end

  def init_block
    magic = [ubyte, ubyte, ubyte, ubyte, ubyte, ubyte]

    if magic == [0x17, 0x72, 0x45, 0x38, 0x50, 0x90]
      complete
    elsif magic != [0x31, 0x41, 0x59, 0x26, 0x53, 0x59]
      @current_state = EOF

      raise 'Bad block header.'
    else
      @stored_block_crc = int
      @block_randomised = bit

      @data = PoiseArchive::Bzip2::InputData.new @block_size if @data.nil?

      get_and_move_to_front_decode

      @crc.initialize_crc
      @current_state = START_BLOCK_STATE
    end
  end

  def end_block
    @computed_block_crc = @crc.final_crc

    if @stored_block_crc != @computed_block_crc
      @computed_combined_crc = (@stored_combined_crc << 1) | (@stored_combined_crc >> 31)
      @computed_combined_crc ^= @stored_block_crc

      raise 'BZip2 CRC error'
    end

    @computed_combined_crc = (@computed_combined_crc << 1) | (@computed_combined_crc >> 31)
    @computed_combined_crc ^= @computed_block_crc
  end

  def complete
    @stored_combined_crc = int
    @current_state = EOF
    @data = nil

    raise 'BZip2 CRC error' if @stored_combined_crc != @computed_combined_crc
  end

  def close
    if @io != $stdin
      @io = nil
      @data = nil
    end
  end

  def r(n)
    live_shadow = @live
    buff_shadow = @buff

    if live_shadow < n
      begin
        thech = @io.readbyte

        raise 'unexpected end of stream' if thech < 0

        buff_shadow = (buff_shadow << 8) | thech
        live_shadow += 8
      end while live_shadow < n

      @buff = buff_shadow
    end

    @live = live_shadow - n

    (buff_shadow >> (live_shadow - n)) & ((1 << n) - 1)
  end

  def bit
    r(1) != 0
  end

  def ubyte
    r 8
  end

  def int
    (((((r(8) << 8) | r(8)) << 8) | r(8)) << 8) | r(8)
  end

  def create_decode_tables(limit, base, perm, length, min_len, max_len, alpha_size)
    pp = 0
    (min_len..max_len).each do |i|
      alpha_size.times do |j|
        if length[j] == i
          perm[pp] = j
          pp += 1
        end
      end
    end

    MAX_CODE_LEN.downto 1 do |i|
      base[i] = 0
      limit[i] = 0
    end

    alpha_size.times do |i|
      base[length[i] + 1] += 1
    end

    b = 0
    1.upto(MAX_CODE_LEN - 1) do |i|
      b += base[i]
      base[i] = b
    end

    vec = 0
    min_len.upto(max_len) do |i|
      b = base[i]
      nb = base[i + 1]
      vec += nb - b
      b = nb
      limit[i] = vec - 1
      vec = vec << 1
    end

    (min_len + 1).upto(max_len) do |i|
      base[i] = ((limit[i - 1] + 1) << 1) - base[i]
    end
  end

  def receive_decoding_tables
    in_use = @data.in_use
    pos = @data.receive_decoding_tables_pos
    selector = @data.selector
    selector_mtf = @data.selector_mtf

    in_use16 = 0

    16.times do |i|
      in_use16 |= 1 << i if bit
    end

    255.downto(0) do |i|
      in_use[i] = false
    end

    16.times do |i|
      if (in_use16 & (1 << i)) != 0
        i16 = i << 4
        16.times do |j|
          in_use[i16 + j] = true if bit
        end
      end
    end

    make_maps
    alpha_size = @n_in_use + 2

    groups = r 3
    selectors = r 15

    selectors.times do |i|
      j = 0
      while bit
        j += 1
      end
      selector_mtf[i] = j
    end

    groups.downto(0) do |v|
      pos[v] = v
    end

    selectors.times do |i|
      v = selector_mtf[i] & 0xff
      tmp = pos[v]

      while v > 0 do
        pos[v] = pos[v -= 1]
      end

      pos[0] = tmp
      selector[i] = tmp
    end

    len = @data.temp_char_array_2d

    groups.times do |t|
      curr = r 5
      len_t = len[t]
      alpha_size.times do |i|
        while bit
          curr += bit ? -1 : 1
        end
        len_t[i] = curr
      end
      @data.temp_char_array_2d[t] = len_t
    end

    create_huffman_decoding_tables alpha_size, groups
  end

  def create_huffman_decoding_tables(alpha_size, groups)
    len = @data.temp_char_array_2d
    min_lens = @data.min_lens
    limit = @data.limit
    base = @data.base
    perm = @data.perm

    groups.times do |t|
      min_len = 32
      max_len = 0
      len_t = len[t]

      (alpha_size - 1).downto 0 do |i|
        lent = len_t[i]
        max_len = lent if lent > max_len
        min_len = lent if lent < min_len
      end

      create_decode_tables limit[t], base[t], perm[t], len[t], min_len, max_len, alpha_size
      min_lens[t] = min_len
    end
  end

  def get_and_move_to_front_decode
    @orig_ptr = r 24
    receive_decoding_tables

    ll8 = @data.ll8
    unzftab = @data.unzftab
    selector = @data.selector
    seq_to_unseq = @data.seq_to_unseq
    yy = @data.get_and_move_to_front_decode_yy
    min_lens = @data.min_lens
    limit = @data.limit
    base = @data.base
    perm = @data.perm
    limit_last = @block_size * BASEBLOCKSIZE

    256.downto(0) do |i|
      yy[i] = i
      unzftab[i] = 0
    end

    group_no = 0
    group_pos = G_SIZE - 1
    eob = @n_in_use + 1
    next_sym = get_and_move_to_front_decode0 0
    buff_shadow = @buff
    live_shadow = @live
    last_shadow = -1
    zt = selector[group_no] & 0xff
    base_zt = base[zt]
    limit_zt = limit[zt]
    perm_zt = perm[zt]
    min_lens_zt = min_lens[zt]

    while next_sym != eob
      if (next_sym == RUNA) || (next_sym == RUNB)
        s = -1

        n = 1
        while true do
          if next_sym == RUNA
            s += n
          elsif next_sym == RUNB
            s += n << 1
          else
            break
          end

          if group_pos == 0
            group_pos = G_SIZE - 1
            group_no += 1
            zt = selector[group_no] & 0xff
            base_zt = base[zt]
            limit_zt = limit[zt]
            perm_zt = perm[zt]
            min_lens_zt = min_lens[zt]
          else
            group_pos -= 1
          end

          zn = min_lens_zt

          while live_shadow < zn
            thech = @io.readbyte

            raise 'unexpected end of stream' if thech < 0

            buff_shadow = ((buff_shadow << 8) & 0xffffffff) | thech
            live_shadow += 8
          end

          zvec = ((buff_shadow >> (live_shadow - zn)) & 0xffffffff) & ((1 << zn) - 1)
          live_shadow -= zn

          while zvec > limit_zt[zn]
            zn += 1

            while live_shadow < 1
              thech = @io.readbyte

              raise 'unexpected end of stream' if thech < 0

              buff_shadow = ((buff_shadow << 8) & 0xffffffff) | thech
              live_shadow += 8
            end

            live_shadow -= 1
            zvec = (zvec << 1) | ((buff_shadow >> live_shadow) & 1)
          end

          next_sym = perm_zt[zvec - base_zt[zn]]

          n = n << 1
        end

        ch = seq_to_unseq[yy[0]]
        unzftab[ch & 0xff] += s + 1

        while s >= 0
          last_shadow += 1
          ll8[last_shadow] = ch
          s -= 1
        end

        raise 'block overrun' if last_shadow >= limit_last
      else
        last_shadow += 1
        raise 'block overrun' if last_shadow >= limit_last

        tmp = yy[next_sym - 1]
        unzftab[seq_to_unseq[tmp] & 0xff] += 1
        ll8[last_shadow] = seq_to_unseq[tmp]

        yy[1, next_sym - 1] = yy[0, next_sym - 1]
        yy[0] = tmp

        if group_pos == 0
          group_pos = G_SIZE - 1
          group_no += 1
          zt = selector[group_no] & 0xff
          base_zt = base[zt]
          limit_zt = limit[zt]
          perm_zt = perm[zt]
          min_lens_zt = min_lens[zt]
        else
          group_pos -= 1
        end

        zn = min_lens_zt

        while live_shadow < zn
          thech = @io.readbyte

          raise 'unexpected end of stream' if thech < 0

          buff_shadow = ((buff_shadow << 8) & 0xffffffff) | thech
          live_shadow += 8
        end
        zvec = (buff_shadow >> (live_shadow - zn)) & ((1 << zn) - 1)
        live_shadow -= zn

        while zvec > limit_zt[zn]
          zn += 1
          while live_shadow < 1
            thech = @io.readbyte

            raise 'unexpected end of stream' if thech < 0

            buff_shadow = ((buff_shadow << 8) & 0xffffffff) | thech
            live_shadow += 8
          end
          live_shadow -= 1
          zvec = (zvec << 1) | ((buff_shadow >> live_shadow) & 1)
        end

        next_sym = perm_zt[zvec - base_zt[zn]]
      end
    end

    @last = last_shadow
    @live = live_shadow
    @buff = buff_shadow
  end

  def get_and_move_to_front_decode0(group_no)
    zt = @data.selector[group_no] & 0xff
    limit_zt = @data.limit[zt]
    zn = @data.min_lens[zt]
    zvec = r zn
    live_shadow = @live
    buff_shadow = @buff

    while zvec > limit_zt[zn]
      zn += 1

      while live_shadow < 1
        thech = @io.readbyte

        raise 'unexpected end of stream' if thech < 0

        buff_shadow = ((buff_shadow << 8) & 0xffffffff) | thech
        live_shadow += 8
      end

      live_shadow -=1
      zvec = (zvec << 1) | ((buff_shadow >> live_shadow) & 1)
    end

    @live = live_shadow
    @buff = buff_shadow

    @data.perm[zt][zvec - @data.base[zt][zn]]
  end

  def setup_block
    return if @data.nil?

    cftab = @data.cftab
    tt = @data.init_tt @last + 1
    ll8 = @data.ll8
    cftab[0] = 0
    cftab[1, 256] = @data.unzftab[0, 256]

    c = cftab[0]
    1.upto(256) do |i|
      c += cftab[i]
      cftab[i] = c
    end

    last_shadow = @last
    (last_shadow + 1).times do |i|
      cftab_i = ll8[i] & 0xff
      tt[cftab[cftab_i]] = i
      cftab[cftab_i] += 1
    end

    raise 'stream corrupted' if @orig_ptr < 0 || @orig_ptr >= tt.size

    @su_t_pos = tt[@orig_ptr]
    @su_count = 0
    @su_i2 = 0
    @su_ch2 = 256

    if @block_randomised
      @su_r_n_to_go = 0
      @su_r_t_pos = 0

      setup_rand_part_a
    else
      setup_no_rand_part_a
    end
  end

  def setup_rand_part_a
    if @su_i2 <= @last
      @su_ch_prev = @su_ch2
      su_ch2_shadow = @data.ll8[@su_t_pos] & 0xff
      @su_t_pos = @data.tt[@su_t_pos]

      if @su_r_n_to_go == 0
        @su_r_n_to_go = RNUMS[@su_r_t_pos] - 1
        @su_r_t_pos += 1
        @su_r_t_pos = 0 if @su_r_t_pos == 512
      else
        @su_r_n_to_go -= 1
      end

      @su_ch2 = su_ch2_shadow ^= (@su_r_n_to_go == 1) ? 1 : 0
      @su_i2 += 1
      @current_char = su_ch2_shadow
      @current_state = RAND_PART_B_STATE
      @crc.update_crc su_ch2_shadow
    else
      end_block
      init_block
      setup_block
    end
  end

  def setup_no_rand_part_a
    if @su_i2 <= @last
      @su_ch_prev = @su_ch2
      su_ch2_shadow = @data.ll8[@su_t_pos] & 0xff
      @su_ch2 = su_ch2_shadow
      @su_t_pos = @data.tt[@su_t_pos]
      @su_i2 += 1
      @current_char = su_ch2_shadow
      @current_state = NO_RAND_PART_B_STATE
      @crc.update_crc su_ch2_shadow
    else
      @current_state = NO_RAND_PART_A_STATE
      end_block
      init_block
      setup_block
    end
  end

  def setup_rand_part_b
    if @su_ch2 != @su_ch_prev
      @current_state = RAND_PART_A_STATE
      @su_count = 1
      setup_rand_part_a
    else
      @su_count += 1
      if @su_count >= 4
        @su_z = @data.ll8[@su_t_pos] & 0xff
        @su_t_pos = @data.tt[@su_t_pos]

        if @su_r_n_to_go == 0
          @su_r_n_to_go = RNUMS[@su_r_t_pos] - 1
          @su_r_t_pos += 1
          @su_r_t_pos = 0 if @su_r_t_pos == 512
        else
          @su_r_n_to_go -= 1
        end

        @su_j2 = 0
        @current_state = RAND_PART_C_STATE
        @su_z ^= 1 if @su_r_n_to_go == 1
        setup_rand_part_c
      else
        @current_state = RAND_PART_A_STATE
        setup_rand_part_a
      end
    end
  end

  def setup_rand_part_c
    if @su_j2 < @su_z
      @current_char = @su_ch2
      @crc.update_crc @su_ch2
      @su_j2 += 1
    else
      @current_state = RAND_PART_A_STATE
      @su_i2 += 1
      @su_count = 0
      setup_rand_part_a
    end
  end

  def setup_no_rand_part_b
    if @su_ch2 != @su_ch_prev
      @su_count = 1
      setup_no_rand_part_a
    else
      @su_count += 1
      if @su_count >= 4
        @su_z = @data.ll8[@su_t_pos] & 0xff
        @su_t_pos = @data.tt[@su_t_pos]
        @su_j2 = 0
        setup_no_rand_part_c
      else
        setup_no_rand_part_a
      end
    end
  end

  def setup_no_rand_part_c
    if @su_j2 < @su_z
      su_ch2_shadow = @su_ch2
      @current_char = su_ch2_shadow
      @crc.update_crc su_ch2_shadow
      @su_j2 += 1
      @current_state = NO_RAND_PART_C_STATE
    else
      @su_i2 += 1
      @su_count = 0
      setup_no_rand_part_a
    end
  end

  def size
    if @io.is_a? StringIO
      @io.size
    elsif @io.is_a? File
      @io.stat.size
    end
  end

  def uncompressed
    @last + 1
  end

  def inspect
    "#<#{self.class}: @io=#{@io.inspect} size=#{size} uncompressed=#{uncompressed}>"
  end

end
