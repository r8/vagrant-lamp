#
# Cookbook:: mingw
# Resource:: tdm_gcc
#
# Copyright:: 2016, Chef Software, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# Installs a gcc based C/C++ compiler and runtime from TDM GCC.

property :flavor, Symbol, is: [:sjlj_32, :seh_sjlj_64], default: :seh_sjlj_64
property :root, String, required: true
property :version, String, is: ['5.1.0'], name_property: true

resource_name :mingw_tdm_gcc

tdm_gcc_64 = {
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-core.tar.lzma' =>
    '29393aac890847089ad1e93f81a28f6744b1609c00b25afca818f3903e42e4bd',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/MinGW-w64%20runtime/GCC%205%20series/mingw64runtime-v4-git20150618-gcc5-tdm64-1.tar.lzma' =>
    '29186e0bb36824b10026d78bdcf238d631d8fc1d90718d2ebbd9ec239b6f94dd',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/GNU%20binutils/binutils-2.25-tdm64-1.tar.lzma' =>
    '4722bb7b4d46cef714234109e25e5d1cfd29f4e53365b6d615c8a00735f60e40',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm64-1/gcc-5.1.0-tdm64-1-c%2B%2B.tar.lzma' =>
    '17fd497318d1ac187a113e8665330d746ad9607a0406ab2374db0d8e6f4094d1',
}

tdm_gcc_32 = {
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-core.tar.lzma' =>
    '9199e6ecbce956ff4704b52098beb38e313176ace610285fb93758a08752870e',
  'http://iweb.dl.sourceforge.net/project/tdm-gcc/TDM-GCC%205%20series/5.1.0-tdm-1%20SJLJ/gcc-5.1.0-tdm-1-c%2B%2B.tar.lzma' =>
    '19fe46819ce43531d066b438479300027bbf06da57e8a10be5100466f80c28fc',
}

action :install do
  cache_dir = ::File.join(root, '.cache')
  f_root = win_friendly_path(root)

  if flavor == :sjlj_32
    [
      'binutils-bin=2.25.1',
      'libintl-dll=0.18.3.2',
      'mingwrt-dll=3.21.1',
      'mingwrt-dev=3.21.1',
      'w32api-dev=3.17',
    ].each do |package_fragment|
      mingw_get "install #{package_fragment} at #{f_root}" do
        package "mingw32-#{package_fragment}-*"
        root new_resource.root
      end
    end
  end

  to_fetch =
    case flavor
    when :sjlj_32
      tdm_gcc_32
    when :seh_sjlj_64
      tdm_gcc_64
    else
      raise "Unknown flavor: #{flavor}"
    end

  to_fetch.each do |url, hash|
    seven_zip_archive "cache #{archive_name(url)} to #{win_friendly_path(cache_dir)}" do
      source url
      path cache_dir
      checksum hash
      overwrite true
    end

    seven_zip_archive "extract #{tar_name(url)} to #{f_root}" do
      source ::File.join(cache_dir, tar_name(url))
      path root
      overwrite true
    end
  end

  # Patch time.h headers for compatibility with winpthreads.
  # These patches were made for binutils 2.25.1 for 32-bit TDM GCC only.
  if flavor == :sjlj_32
    include_dir = win_friendly_path(::File.join(root, 'include'))
    cookbook_file "#{include_dir}\\pthread.h" do
      cookbook 'mingw'
      source 'pthread.h'
    end

    cookbook_file "#{include_dir}\\time.h" do
      cookbook 'mingw'
      source 'time.h'
    end
  end
end

def archive_name(source)
  url = ::URI.parse(source)
  ::File.basename(::URI.unescape(url.path))
end

def tar_name(source)
  aname = archive_name(source)
  ::File.basename(aname, ::File.extname(aname))
end
