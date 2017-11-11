# This code is free software; you can redistribute it and/or modify it under
# the terms of the new BSD License.
#
# Copyright (c) 2013, Sebastian Staudt


module PoiseArchive::Bzip2

  autoload :CRC,          'poise_archive/bzip2/crc'
  autoload :Constants,    'poise_archive/bzip2/constants'
  autoload :Decompressor, 'poise_archive/bzip2/decompressor'
  autoload :IO,           'poise_archive/bzip2/io'
  autoload :InputData,    'poise_archive/bzip2/input_data'
  autoload :OutputData,   'poise_archive/bzip2/output_data'

end
