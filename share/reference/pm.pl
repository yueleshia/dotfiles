#!/bin/perl

use v5.28;                     # in perluniintro, latest bug fix for unicode
use feature 'unicode_strings'; # enable perl functions to use Unicode
use Encode 'decode_utf8';      # so we do not need -CA flag in perl
use utf8;                      # source code in utf8
use strict;
use warnings;

my $DESCRIPTION = <<EOF;
  Package manager
EOF

binmode(STDIN, ":utf8");
binmode(STDOUT, ":utf8");
binmode(STDERR, ":utf8");

my $FLAG = 0; # Does not take an arg, e.g. --verbose
my $ARG = 1;  # Takes an argument,    e.g. --target hello
# short (optional), long, aliases (with ignore), bool, short desc, long desc
my $SHORT = 0;
my $LONG = 1;
my $ALIASES = 2;
my $TAKE_ARG = 3;
my $SHORT_DESCRIPTION = 4;
my $LONG_DESCRIPTION = 5;

my @ACTIONS = sort { $a->[$SHORT] cmp $b->[$SHORT] } (
  ["C", "Config", [], $FLAG, "Rewrite all", "
    Config"
  ],

  ["I", "Install", [], $FLAG, "Only rewrite symlinks", "
    "
  ],

  ["Q", "Query", [], $FLAG, "Search for a package", "
    Does not replace with the symlink if the destination file already exists.
    The default behaviour and useful if you want to keep your current config"
  ],

  ["G", "git", [], $ARG, "Set destination directory to ARG", "
    Changes the destination to which all the config files are symlinked
    Default is '\${HOME}'"
  ],
  ["", "help", [], $FLAG, "Display long help", "
    Use a CSV file"
  ],

  ["h", "help", [], $FLAG, "Display long help", "
    Display this help menu"
    /#*/ {
    }
  ],

);
my @OPTIONS = sort { $a->[$SHORT] cmp $b->[$SHORT] } (
  ["f", "force", [], $FLAG, "Rewrite all", "
    Deletes the destination forcefully and symlinks. In particular, this is
    Useful if programs are run and the config files are already created in
    order to replace them with the dotfiles"
  ],

  ["c", "cautious", [], $FLAG, "Only rewrite symlinks", "
    Only ."
  ],

  ["i", "ignore", [], $FLAG, "Skip if file exists", "
    Does not replace with the symlink if the destination file already exists.
    The default behaviour and useful if you want to keep your current config"
  ],

  ["h", "help", [], $FLAG, "Display long help", "
    Display this help menu"
  ],

  ["o", "output", [], $ARG, "Set destination directory to ARG", "
    Changes the destination to which all the config files are symlinked
    Default is '\${HOME}'"
  ],

  ["v", "verbose", [], $FLAG, "Verbose output", "
    Mutes any warnings (ie. when symlinks are left alone because they already
    exist)"
  ],
);



my $IS_DATUM = 1;
my $IS_STDIN = 1;

#run: perl -T % Q

sub main {
  show_help($LONG);
}


################################################################################
# Argument and Option parsing
sub parse_valid_options {
  my %valid_options;
  my @options_spec = @_;
  my $index = 0;
  for my $option_def (@options_spec) {
    length($option_def->[$SHORT]) <= 1 or die
        "DEV: Short options are the empty string or one character";

    if (length($option_def->[$SHORT]) == 1) {
      $valid_options{$option_def->[$SHORT]} = $index;
    }

    $valid_options{$option_def->[$LONG]} = $index;
    for my $alias (@{$option_def->[$ALIASES]}) {
      $valid_options{$alias} = $index;
    }
    ++$index;
  }
  return %valid_options;
}

# Returns \@opts and \@args
# @opts: [index0, arg0, index1, arg1, ...]
# @args: [is_stdin_0, datum_0, is_stdin_1, datum_1, ...]
#
# index is an index into $_[1]
sub parse_args {
  my %valid_options = %{shift()};
  my @options_spec = @{shift()};

  my $stdin = 0;
  my $literal = 0;
  my @opts;
  my @args;
  while (scalar(@_) > 0) {
    my $arg = shift();
    if (!utf8::is_utf8($arg)) {
      $arg = Encode::decode_utf8($arg);
    }

    my @to_check;
    if ($literal) {
      push @args, $IS_DATUM;
      push @args, $arg;
    } elsif ($arg eq "-") {
      push @args, $IS_STDIN;
      push @args, 0;
    } elsif ($arg eq "--") {
      $literal = 1;
    } elsif (substr($arg, 0, 2) eq "--") {
      push @to_check, substr($arg, 2);
    } elsif (substr($arg, 0, 1) eq "-") {
      @to_check = split //, substr($arg, 1);
    } else {
      push @args, $arg;
    }

# run: perl -T % -o a h --help yo
# run: perl -CA -T % -o a -你 --help yo
    for my $i (0..$#to_check) {
      my $o = $to_check[$i];
      my $index = $valid_options{$o};

      if (not exists $valid_options{$o} or not defined $valid_options{$o}) {
        die "FATAL: Invalid option '" . (length($o) <= 1 ? "-$o" : "--$o") . "'";
      } elsif ($OPTIONS[$index][$TAKE_ARG]) {
        if ($i != $#to_check) {
          die "FATAL: Option '$o' takes an argument";
        } else {
          push @opts, $index;
          push @opts, decode_utf8(shift(@_));
        }
      } else {
        push @opts, $index;
        push @opts, 1;
      }
    }
  }

  return \@opts, \@args;
}

# Input: the options_spec
sub display_options {
  if ($_[0] eq $SHORT) {
    # Calculate the padding
    my $padding = 0;
    for my $def (@{$_[1]}) {
      for my $long_opt ($def->[$LONG], @{$def->[$ALIASES]}) {
        my $len = length($long_opt);
        $padding = $padding > $len ? $padding : $len;
      }
    }

    for my $def (@{$_[1]}) {
      print "  ";
      print($def->[$SHORT] ne "" ? "-$def->[$SHORT], " : "    ");
      printf("--%-${padding}s  ", $def->[$LONG]);
      print($def->[$TAKE_ARG] ? "ARG": "   ");
      print "  ";
      say $def->[$SHORT_DESCRIPTION];
      for (@{$def->[$ALIASES]}) {
        printf("      %-${padding}s  ", $_);
        say '';
      }
    }
  } else {
    # Assume @options is sorted already
    for my $def (@{$_[1]}) {
      # print options
      print "  ";
      my $i = 0;
      my @opts;
      $def->[$SHORT] ne "" and push(@opts, "-$def->[$SHORT]");
      $def->[$LONG]  ne "" and push(@opts, " --$def->[$LONG]");
      print join(", ", (@opts, @{$def->[$ALIASES]}));
       #print join(", ", ("-$entry[1]", "--$long", @{$entry[2]}));
        #}

      print "$def->[$LONG_DESCRIPTION]\n\n";
    }
  }
}

sub show_help {
  my $NAME = $0;
  my $synopsis = "$NAME [OPTION]";
  # Adds --
  my $literal = ["", "", [], $FLAG, "Stop parsing subsequent args as options", "
    Makes all subsequent arguments not be interpretted at options. Good for
    passing files names that begin with a hyphen/dash."
  ];
  my @options_spec = ($literal, @OPTIONS);
  # Short
  if ($_[0] eq $SHORT) {
    say $synopsis;
    display_options($_[0], \@options_spec);

  # Long
  } elsif ($_[0] eq $LONG) {
    print <<EOF;
SYNOPSIS
  $synopsis;

DESCRIPTION
$DESCRIPTION

ARGUMENTS
  -
    Using '-' for an argument means pipe it

OPTIONS
  `display_options()`

EOF
    display_options($_[0], \@options_spec);

  } else {
    die "DEV: pass `show_help()` the 'short' or 'long' argument"
  }
}

main();


##!/bin/perl
#
#use v5.14;
#use strict 'subs'; # avoid barewords
#use warnings;
#
#sub list_zettles {
#  my $uniq_id = "/./";
#  $ENV{"PATH"} = ""; # For de-tainting (perl -T)
#  my $find = qx(/bin/find -L "$uniq_id$_[0]" -type f);
#  $find = substr($find, length($uniq_id), -1); # minus trailing newline
#  return split(m|\n/./|, $find);
#}
#
#sub trim { return $_[0] =~ s/^\s+|\s+$//rg; }
#sub qx_escapequote { return "'" . $_[0] =~ s/'/'\\''/rg . "'"; }
#
#my @supported_types = ("md", "adoc");
#
#
#sub extract_metadata {
#  my ($path, $ext, $short) = @_;
#  my $title = "";
#  my $tags = "";
#  my $is_supported_type = 0;
#
#  open(FILE, $path) or print "Could not open '$path'";
#  $path =~ /\|/ and die "'$path' has an invalid bar in its path";
#
#  if ($ext eq "md") {
#    $is_supported_type = 1;
#
#    my ($h_tags, $h_title) = ("tags:", "title:");
#    my $l_tags =  length($h_tags);
#    my $l_title = length($h_title);
#    while (<FILE>) { substr($_, 0, 4) eq "----" && last; } # Skip till first ----
#    while (<FILE>) { substr($_, 0, 4) eq "----" && last; # last after second ----
#      if (substr($_, 0, $l_tags) eq $h_tags) { $tags = substr($_, $l_tags); }
#      elsif (substr($_, 0, $l_title) eq $h_title) { $title = substr($_, $l_title); }
#    }
#
#  } elsif ($ext eq "adoc") {
#    $is_supported_type = 1;
#
#    my ($h_tags, $h_title) = (":tags:", ":title:");
#    my $l_tags =  length($h_tags);
#    my $l_title = length($h_title);
#    while (<FILE>) {
#      if ($title ne "" && $tags ne "") { last; } # last when both are found
#
#      if (substr($_, 0, $l_tags) eq $h_tags) { $tags = substr($_, $l_tags); }
#      elsif (substr($_, 0, $l_title) eq $h_title) { $title = substr($_, $l_title); }
#    }
#  } else {
#    print STDERR "'$short' is not a supported file extension '$ext'\n";
#  }
#  close FILE;
#
#
#  $title = trim($title);
#  $tags = trim($tags);
#
#  # Just to make it easier to work with shell
#  # If I transition this to rust, this will not be a problem
#  $title =~ /\\/ and die "'$short' has an invalid backslash in title '$title'";
#  $tags =~ /\\/ and die "'$short' has an invalid backslash in tags '$tags'";
#  #$tags =~ /'/ and die "'$short' has an invalid single quote in tags '$tags'";
#
#  $title =~ /\|/ and die "'$short' has an invalid bar in title '$title'";
#  $tags =~ /\|/ and die "'$short' has an invalid bar in tags '$tags'";
#  $title =~ /`/ and die "'$short' has an invalid backtick in title '$title'";
#  $tags =~ /`/ and die "'$short' has an invalid backtick in tags '$tags'";
#
#  # This is algorithmically impossible
#  #$title =~ /\n/ and die "'$short' has an invalid newline in title '$title'";
#  #$tags =~ /\n/ and die "'$short' has an invalid newline in tags '$tags'";
#
#  $tags = $tags eq "" ? "Untagged" : $tags;
#  $is_supported_type && $title eq "" and die "'$short' does not have a title";
#
#  return ($title, $tags);
#}
#
#my $ZK_DIR = "/home/rai/interim/zet/src";
#
#sub list_tags {
#  my @paths = list_zettles($ZK_DIR);
#  my @exts = map { $_ =~ /\.(.*)$/; $1 } @paths;
#  my @shorts = map { substr($_, length($ZK_DIR) + 1) } @paths;
#  $ENV{"PATH"} = ""; # For de-tainting (perl -T)
#
#  my $j = 0;
#  for my $i (0..$#paths) {
#    my ($path, $ext, $short) = ($paths[$i], $exts[$i], $shorts[$i]);
#    my ($title, $tags) = extract_metadata($path, $ext, $short);
#
#    # 'extract_metadata' constraint: title cannot have: \ ` |
#    # 'extract_metadata' constraint: tags cannot have: \ ` ' |
#    if ($title ne "") { # Not a supported filetype
#      $j += 1;
#      say "$j|$path|$short|$tags|$title";
#    }
#  }
#}
#
#sub extract_links {
#  my ($path, $ext, $short) = @_;
#  open(FILE, '<:encoding(UTF-8)', $path) or print "Could not open '$path'";
#  if ($ext eq "md") {
#    # '[' and ']' not preceeded by backslash
#    while (<FILE>) {
#      #my @matches = $_ =~ /\[(?<!\\)(?>\\\\)*\]/g;
#
#      # Common mark spec is a bit more detailed than this
#      # but this will have to do for now
#      my @matches = $_ =~ /\[(?<!\\)(?>\\\\)*[\s\S]*?\]\(.*\)/g;
#      print @matches;
#    }
#  } elsif ($ext eq "adoc") {
#
#  } else {
#    print STDERR "'$short' is not a supported file extension '$ext'\n";
#  }
#  close FILE;
#}
#
#sub links_here {
#}
#
#sub rename_link {
#}
#
#extract_links("$ZK_DIR/shell-scripting.md", "md");
#
#__END__

#sub show_help {
#  print STDERR "This is the temp help\n";
#  print STDERR "Available commands are: TODO\n";
#}
#
## Parse args
#my @arg;
#my $literal = 0;
#while (@ARGV) {
#  my $arg = shift @ARGV;
#  $literal = $literal || ($arg eq '--');
#
#  my @opts;
#  unless ($literal) {
#    if (substr($arg, 0, 2) eq '--') {
#      push @opts, substr($arg, 2);
#    } elsif (substr($arg, 0, 1) eq '-') {
#      @opts = split //, substr($arg, 1);
#    } else {
#      push @arg, $arg;
#    }
#    for my $o (@opts)  {
#      ($o eq 'h' || $o eq 'help') && print "help\n";
#      #($o eq 'v' || $o eq 'help') && print "help\n";
#    }
#  } else {
#    push @arg, $arg;
#  }
#}
#
##my $ZK_DIR = $ENV{'ZETTLEKASTEN_DIR'} or die "\$ZETTLEKASTEN_DIR is not defined";;
#sub main {
#  if ($#_ < 0) { show_help; exit 1 }
#  my $subcommand = shift @_;
#
#  if ($subcommand eq 'help') { show_help; exit 1; }
#  elsif ($subcommand eq 'rename') {  print "yes"; }
#  elsif ($subcommand eq 'ot') {  print "yes"; }
#  elsif ($subcommand eq 'tags') {  do_tags(@_) }
#  elsif ($subcommand eq 'name') {  print "yes"; }
#  elsif ($subcommand eq 'string') {  print "yes"; }
#  elsif ($subcommand eq 'verify') {  print "yes"; }
#  else { print STDERR "Subcommand '$subcommand' is not supported\n"; exit 1; }
#
#}


