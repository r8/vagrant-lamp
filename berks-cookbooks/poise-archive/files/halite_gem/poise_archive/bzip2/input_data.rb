# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2011-2013, Sebastian Staudt


class PoiseArchive::Bzip2::InputData

  include PoiseArchive::Bzip2::Constants

  attr_reader :base, :cftab, :get_and_move_to_front_decode_yy, :in_use,
              :limit, :ll8, :min_lens, :perm, :receive_decoding_tables_pos,
              :selector, :selector_mtf, :seq_to_unseq, :temp_char_array_2d,
              :unzftab, :tt

  def initialize(block_size)
    @in_use = Array.new 256, false

    @seq_to_unseq = Array.new 256, 0
    @selector = Array.new MAX_SELECTORS, 0
    @selector_mtf = Array.new MAX_SELECTORS, 0

    @unzftab = Array.new 256, 0

    @base = Array.new(N_GROUPS) { Array.new(MAX_ALPHA_SIZE, 0) }
    @limit = Array.new(N_GROUPS) { Array.new(MAX_ALPHA_SIZE, 0) }
    @perm = Array.new(N_GROUPS) { Array.new(MAX_ALPHA_SIZE, 0) }
    @min_lens = Array.new N_GROUPS, 0

    @cftab = Array.new 257, 0
    @get_and_move_to_front_decode_yy = Array.new 256
    @temp_char_array_2d = Array.new(N_GROUPS) { Array.new(MAX_ALPHA_SIZE, 0) }
    @receive_decoding_tables_pos = Array.new N_GROUPS, 0

    @ll8 = Array.new block_size * BASEBLOCKSIZE
  end

  def init_tt(size)
    @tt = Array.new(size) if @tt.nil? || @tt.size < size
    @tt
  end

end
