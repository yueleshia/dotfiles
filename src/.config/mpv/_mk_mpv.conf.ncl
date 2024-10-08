#run: nickel export % --field text --format raw

{ executable = false, text = m%"
# https://kokomins.wordpress.com/2019/10/14/mpv-config-guide/
sub-visibility = yes
sub-auto       = fuzzy          # allow external sub files to not match file exactly
alang          = 'jpn,jp,zh,en' # sub selection order
volume         = 60             # start volume %

ytdl-format    = bestvideo[height<=?480]+bestaudio/best

volume-max     = 200            # maximum volume in %

# Audio for improving quality of audio when increasing speed
# https://github.com/mpv-player/mpv/issues/4418
af=scaletempo2
#af=atempo
#af=rubberband=channels=together
#af-add=lavfi="dynaudnorm=m=5:n=0:g=15:f=250:p=0.9:r=0.5"

"% }
