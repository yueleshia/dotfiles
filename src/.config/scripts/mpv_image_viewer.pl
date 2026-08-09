#!/usr/bin/perl

#run: % ~/"Music/youtube/WGgEFoI9MhE-Gawr Gura「REFLECT」.opus"

use strict;
use warnings;
use File::Basename;
use File::Spec;

my $target = $ARGV[0];
my $parent = dirname($target);

sub endswith {
  return 0 if length($_[0]) < length($_[1]);
  return substr($_[0], length($_[0]) - length($_[1])) eq $_[1];
}

opendir(my $FH, $parent) or die "Cannot open '$parent'";
my @list;
while (my $name = readdir($FH)) {
  #next if not -f $name;
  foreach my $ext (
    ".svg",
    ".jpg", ".jpeg", ".jpe", ".jif", ".jfif", ".jfi",
    ".png",
    ".gif",
    ".webp",
    ".tiff", ".tif",
    ".psd",
    ".raw", ".arw", ".cr2", ".nrw", ".k25",
    ".bmp", ".dib",
    ".heif", ".heic",
    ".ind", ".indd", ".indt",
    ".jp2", ".j2k", ".jpf", ".jpx", ".jpm", ".mj2",
    ".ppm", ".pgm", ".pbm", ".pnm",
  ) {
    if (endswith($name, $ext)) {
      push @list, File::Spec->catfile($parent, $name);;
    }
  }
}
#print(join("\n", @list), "\n");
@list = sort @list;
my $i = 0;
my $j = -1;
foreach my $filepath (@list) {
  print($filepath, " vs ", $target);
  if ($filepath eq $target) {
    $j = $i;
  }
  $i += 1;
}
die "$target is not a supported image file extension" if ($j < 0);
closedir($FH);
exit(system("mpv", "--playlist-start=$j", @list))
