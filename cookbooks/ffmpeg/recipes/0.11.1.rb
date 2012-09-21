media_libs   = "/engineyard/portage/media-libs"
media_sound  = "/engineyard/portage/media-sound"
media_video  = "/engineyard/portage/media-video"
dev_lang     = "/engineyard/portage/dev-lang"
dev_python   = "/engineyard/portage/dev-python"

if `uname -m`.strip == 'x86_64' 
  mask = "~amd64"
elsif `uname -m` == 'i686'
  mask = "~x86"
end

ffmpeg       = "ffmpeg-0.11.1"
libtheora    = "libtheora-1.1.1"
openjpeg     = "openjpeg-1.3-r3"
vo_aacenc    = "vo-aacenc-0.1.1"
x264         = "x264-0.0.20120707"
lame         = "lame-3.98.4"
opencore_amr = "opencore-amr-0.1.2"
vo_amrwbenc  = "vo-amrwbenc-0.1.1"
yasm         = "yasm-1.2.0"
cython       = "cython-0.16"
lcms         = "lcms-2.3"
x264_append  = <<EOF

src_install() {
        make DESTDIR="${D}" install || die
        dodoc AUTHORS doc/*.txt
}
EOF
yasm_append  = <<EOF

src_install() {
        emake DESTDIR="${D}" install || die "make install failed"
        dodoc AUTHORS INSTALL
}
EOF

openjpeg_files  = %w(1.4-cmake-stdbool.patch 1.4-libpng15.patch 1.4-linking.patch 1.4-pkgconfig.patch 1.5.0-build.patch 1.3-Makefile.patch 1.3-freebsd.patch 1.3-darwin.patch)
x264_files      = %w(nostrip.patch onlylib-20110425.patch)
lame_files      = %w(3.96-ccc.patch 3.98-gtk-path.patch 3.98.2-get_audio.patch 3.98.2-ffmpeg-0.5.patch)
vo_aacenc_files = %w(0.1.1-neon.patch)
yasm_files      = %w(fix_cython_check.patch)

needed_directories = ["#{media_libs}/vo-aacenc/files", "#{media_libs}/opencore-amr", "#{media_libs}/vo-amrwbenc", "#{dev_lang}/yasm/files"]
masked_packages    = ["media-video/#{ffmpeg}", "media-libs/#{x264}"]

if mask == "~amd64"
  enable_package "media-libs/vo-amrwbenc" do
    version vo_amrwbenc.split('-')[-1]
  end
end

package_use "=media-video/#{ffmpeg}" do
  flags "-ieee1394"
end

masked_packages.each do |package|
  enable_package package do
    override_hardmask true
  end
end

needed_directories.each do |dir|
  execute "creating #{dir}" do
    command "mkdir -p #{dir}"
  end
end

openjpeg_files.each do |file|
  execute "wget #{file}" do
    command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/openjpeg/files/openjpeg-#{file} -P #{media_libs}/openjpeg/files}
  end
end

x264_files.each do |file|
  execute "wget #{file}" do
    command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/x264/files/x264-#{file} -P #{media_libs}/x264/files}
  end
end

lame_files.each do |file|
  execute "wget #{file}" do
    command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-sound/lame/files/lame-#{file} -P #{media_sound}/lame/files}
  end
end

vo_aacenc_files.each do |file|
  execute "wget #{file}" do
    command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/vo-aacenc/files/vo-aacenc-#{file} -P #{media_libs}/vo-aacenc/files}
  end
end

yasm_files.each do |file|
  execute "wget #{file}" do
    command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-lang/yasm/files/#{yasm}-#{file} -P #{dev_lang}/yasm/files}
  end
end

execute "get and digest #{ffmpeg} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-video/ffmpeg/#{ffmpeg}.ebuild -P #{media_video}/ffmpeg && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_video}/ffmpeg/#{ffmpeg}.ebuild && sed -i -r -e 's/virtual\\/pkgconfig/dev-util\\/pkgconfig/g'  #{media_video}/ffmpeg/#{ffmpeg}.ebuild && ebuild #{media_video}/ffmpeg/#{ffmpeg}.ebuild digest}
end
execute "get and digest #{lame} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-sound/lame/#{lame}.ebuild -P #{media_sound}/lame && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_sound}/lame/#{lame}.ebuild && ebuild #{media_sound}/lame/#{lame}.ebuild digest}
end
execute "get and digest #{libtheora} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/libtheora/#{libtheora}.ebuild -P #{media_libs}/libtheora && sed -i -r -e 's/virtual\\/pkgconfig/dev-util\\/pkgconfig/g' #{media_libs}/libtheora/#{libtheora}.ebuild && ebuild #{media_libs}/libtheora/#{libtheora}.ebuild digest}
end
execute "get and digest #{openjpeg} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/openjpeg/#{openjpeg}.ebuild -P #{media_libs}/openjpeg && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_libs}/openjpeg/#{openjpeg}.ebuild && ebuild #{media_libs}/openjpeg/#{openjpeg}.ebuild digest}
end
execute "get and digest #{vo_aacenc} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/vo-aacenc/#{vo_aacenc}.ebuild -P #{media_libs}/vo-aacenc && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_libs}/vo-aacenc/#{vo_aacenc}.ebuild && ebuild #{media_libs}/vo-aacenc/#{vo_aacenc}.ebuild digest}
end
execute "get and digest #{x264} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/x264/#{x264}.ebuild -P #{media_libs}/x264 && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_libs}/x264/#{x264}.ebuild && echo '#{x264_append}' >> #{media_libs}/x264/#{x264}.ebuild && ebuild #{media_libs}/x264/#{x264}.ebuild digest}
end
execute "get and digest #{opencore_amr} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/opencore-amr/#{opencore_amr}.ebuild -P #{media_libs}/opencore-amr && ebuild #{media_libs}/opencore-amr/#{opencore_amr}.ebuild digest}
end
execute "get and digest #{vo_amrwbenc} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/vo-amrwbenc/#{vo_amrwbenc}.ebuild -P #{media_libs}/vo-amrwbenc && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_libs}/vo-amrwbenc/#{vo_amrwbenc}.ebuild && ebuild #{media_libs}/vo-amrwbenc/#{vo_amrwbenc}.ebuild digest}
end
execute "get and digest #{yasm} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-lang/yasm/#{yasm}.ebuild -P #{dev_lang}/yasm && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{dev_lang}/yasm/#{yasm}.ebuild && echo '#{yasm_append}' >> #{dev_lang}/yasm/#{yasm}.ebuild && ebuild #{dev_lang}/yasm/#{yasm}.ebuild digest}
end
execute "get and digest #{cython} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-python/cython/#{cython}.ebuild -P #{dev_python}/cython && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{dev_python}/cython/#{cython}.ebuild && ebuild #{dev_python}/cython/#{cython}.ebuild digest}
end
execute "get and digest #{lcms} ebuild" do
  command %Q{wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/media-libs/lcms/#{lcms}.ebuild -P #{media_libs}/lcms && sed -i -r -e 's/EAPI.*/EAPI="2"/' #{media_libs}/lcms/#{lcms}.ebuild && ebuild #{media_libs}/lcms/#{lcms}.ebuild digest}
end

package "media-video/#{ffmpeg.split('-')[0]}" do
  action :install
  version ffmpeg.split('-')[1]
end
