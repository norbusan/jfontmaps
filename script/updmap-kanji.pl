#!/usr/bin/env perl
# updmap-setup-kanji: setup Japanese font embedding
#
# Copyright 2004-2006 by KOBAYASHI R. Taizo for the shell version (updmap-otf)
# Copyright 2011-2012 by PREINING Norbert
#
# This file is licensed under GPL version 3 or any later version.
# For copyright statements see end of file.
#
# For development see
#  http://www.tug.org/svn/texlive/trunk/Build/source/extra/jfontmaps/
#
# For a changelog see
#  http://www.tug.org/svn/texlive/trunk/Build/source/extra/jfontmaps/ChangeLog
# 

$^W = 1;
use Getopt::Long qw(:config no_autoabbrev ignore_case_always);
use strict;

my $prg = "updmap-setup-kanji";
my $vers = "0.9.6";
my $version = '$Id: updmap-setup-kanji.pl 27277 2012-08-02 00:16:14Z karl $';

my $updmap_real = "updmap";
my $updmap = $updmap_real;

my $dry_run = 0;
my $opt_help = 0;
my $opt_jis = 0;

if (! GetOptions(
        "n|dry-run" => \$dry_run,
        "h|help" => \$opt_help,
        "jis2004" => \$opt_jis,
        "version" => sub { print &version(); exit(0); }, ) ) {
  die "Try \"$0 --help\" for more information.\n";
}


sub win32 { return ($^O=~/^MSWin(32|64)$/i); }

my $nul = (win32() ? 'nul' : '/dev/null') ;


if ($dry_run) {
  $updmap = "echo updmap"; 
}

if ($opt_help) {
  Usage();
  exit 0;
}

#
# representatives of support font families
#
my %representatives = (
  hiragino => "HiraMinPro-W3.otf",
  morisawa => "A-OTF-RyuminPro-Light.otf",
  kozuka   => "KozMinPro-Regular.otf",
  ipa      => "ipam.ttf",
  ipaex    => "ipaexm.ttf",
);
my %available;


main(@ARGV);

sub version {
  my $ret = sprintf "%s version %s\n(svn id: %s)\n", 
    $prg, $vers, $version;
  return $ret;
}

sub Usage {
  my $usage = <<"EOF";
  $prg  Set up embedding of Japanese fonts via updmap.cfg.

                 This script searches for some of the most common fonts
                 for embedding into pdfs by dvipdfmx.

                 In addition it allows to set up arbitrary font families
                 to be embedded into the generated pdf files, as long
                 as at least the map file otf-<family>.map is present.
                 Other map files that will be used if available are
                   
                   ptex-<family>.map
                   uptex-<family>.map
                   otf-up-<family>.map

  Please see the documentation of updmap for details (updmap --help).

  Usage:  $prg [OPTION] {<fontname>|auto|nofont|status}

     <family>    embed an arbitrary font family <family>, at least the
                 map file otf-<family>.map has to be available.
     auto:       embed one of the following supported font families
                 automatically:
                   hiragino, morisawa, kozuka, ipaex, ipa
                 and fall back to not embedding any font if none of them
                 is available
     nofont:     embed no fonts (and rely on system fonts when displaying pdfs)
                 If your system does not have any of the supported font 
                 families as specified above, this target is selected 
                 automatically.
     status:     get information about current environment and usable font map

  Options:
    -n, --dry-run  do not actually run updmap
    -h, --help     show this message and exit
    -jis2004       use JIS2004 variants for default fonts of (u)pTeX
    --version      show version information and exit

EOF
;
  print $usage;
  exit 0;
}



###
### Check Installed Font
###

sub CheckInstallFont {
  for my $k (keys %representatives) {
    my $f = `kpsewhich $representatives{$k}`;
    if (! $?) {
      $available{$k} = chomp($f);
    }
  }
}

###
### GetStatus
###

sub check_mapfile {
  my $mapf = shift;
  my $f = `kpsewhich $mapf 2> $nul`;
  my $ret = $?;
  if (wantarray) {
    return (!$ret, $f);
  } else {
    return (!$ret);
  }
}

sub GetStatus {
  my $val = `$updmap_real --quiet --showoption kanjiEmbed`;
  my $STATUS;
  if ($val =~ m/^kanjiEmbed=([^()\s]*)(\s+\()?/) {
    $STATUS = $1;
  } else {
    printf STDERR "Cannot find status of current kanjiEmbed setting via updmap --showoption!\n";
    exit 1;
  }

  if (check_mapfile("otf-$STATUS.map")) {
    print "CURRENT family : $STATUS\n";
  } else {
    print "WARNING: Currently selected map file cannot be found: otf-$STATUS.map\n";
  }

  for my $k (sort keys %representatives) {
    my $MAPFILE = "otf-$k.map";
    next if ($MAPFILE eq "otf-$STATUS.map");
    if (check_mapfile($MAPFILE)) {
      if ($available{$k}) {
        print "Standby family : $k\n";
      }
    }
  }
  return $STATUS;
}

###
### Setup Map files
###

sub SetupMapFile {
  my $rep = shift;
  my $MAPFILE = "otf-$rep.map";
  if (check_mapfile($MAPFILE)) {
    print "Setting up ... $MAPFILE\n";
    system("$updmap --quiet --nomkmap --nohash -setoption kanjiEmbed $rep");
    if ($opt_jis) {
      system("$updmap --quiet --nomkmap --nohash -setoption kanjiVariant -04");
    } else {
      system("$updmap --quiet --nomkmap --nohash -setoption kanjiVariant \"\"");
    }
    system("$updmap");
  } else {
    print "NOT EXIST $MAPFILE\n";
    exit 1;
  }
}

sub SetupReplacement {
  my $rep = shift;
  if (defined($representatives{$rep})) {
    if ($available{$rep}) {
      return SetupMapFile($rep);
    } else {
      printf STDERR "$rep not available, falling back to auto!\n";
      return SetupReplacement("auto");
    }
  } else {
    if ($rep eq "nofont") {
      return SetupMapFile("noEmbed");
    } elsif ($rep eq "auto") {
      my $STATUS = GetStatus();
      # first check if we have a status set and the font is installed
      # in this case don't change anything, just make sure
      if (defined($representatives{$STATUS}) && $available{$STATUS}) {
        return SetupMapFile($STATUS);
      } else {
        if (!($STATUS eq "noEmbed" || $STATUS eq "")) {
          # some unknown setting is set up currently, overwrite, but warn
          print "Previous setting $STATUS is unknown, replacing it!\n"
        }
        # if we are in the noEmbed or nothing set case, but one
        # of the three fonts hiragino/morisawa/kozuka are present
        # then use them
        for my $i (qw/hiragino morisawa kozuka ipaex ipa/) {
          if ($available{$i}) {
            return SetupMapFile($i);
          }
        }
        # still here, no map file found!
        return SetupMapFile("noEmbed");
      }
    } else {
      # anything else is treated as a map file name
      return SetupMapFile($rep);
    }
  }
}

###
### MAIN
###

sub main {
  my ($a, $b) = @_;

  CheckInstallFont();

  if (!defined($a) || defined($b)) {
    Usage();
    exit 1;
  }

  if ($a eq "status") {
    GetStatus();
    exit 0;
  }

  return SetupReplacement($a);
}

#
#
# Copyright statements:
#
# KOBAYASHI Taizo
# email to preining@logic.at
# Message-Id: <20120130.162953.59640143170594580.tkoba@cc.kyushu-u.ac.jp>
# Message-Id: <20120201.105639.625859878546968959.tkoba@cc.kyushu-u.ac.jp>
# --------------------------------------------------------
# copyright statement は簡単に以下で結構です。
#
#        Copyright 2004-2006 by KOBAYASHI Taizo
#
# では
#        GPL version 3 or any later version
#
# --------------------------------------------------------
#
# PREINING Norbert
# as author and maintainer of the current file
# Licensed under GPL version 3 or any later version
#
### Local Variables:
### perl-indent-level: 2
### tab-width: 2
### indent-tabs-mode: nil
### End:
# vim: set tabstop=2 expandtab autoindent:
