#!/usr/bin/env perl
#
# kanji-fontmap-creator
# (c) 2012 Norbert Preining
# Licenced under the GPLv2 or any higher version
#
# gui to create map files for updmap(-setup-kanji)
#
# ptex/uptex:
#  2 fonts (rml/gbm)
#  2 variants
#  (ev vertical/horizontal)
#
# otf/otf-up:
#  
#  2 variants
#  fonts:
#    gothic: regular, bold, heavy, maru
#    mincho: regular, bold, light
#
# possible improvements:
# - allow editing current files by reading and interpreting them
#   needs better structure of the data
# - specify output directory, automatically write to $TEXMFLOCAL ?
# - more checks, warnings?
#

$^W = 1;
use strict;

use Tk;
use Tk::NoteBook;
use Tk::Dialog;
use Cwd;
use Getopt::Long qw(:config no_autoabbrev);
use Pod::Usage;

my $opt_lang = "en";
my $opt_help = 0;
my $opt_version = 0;

my $prg = "kanji-fontmap-creator";
my $svnrev = '$Revision: 29111 $';
$svnrev =~ m/: ([0-9]+) /;
my $version = "0.1 (svn$svnrev)";


#
# global vars configuring operation
my $group_name = "";
my $do_vertical = 0;
my $do_iso2004  = 0;
my $do_otf      = 0;
my @f_mincho_regular; my @f_gothic_regular;
my @f_mincho_bold; my @f_gothic_bold;
my @f_gothic_heavy;
my @f_gothic_maru;
my @f_mincho_light;
my $b_save;

my $iso_i  = 1;
my $vert_i = 2;
my $isovert_i = 3;
my @order;

my $mw;

$order[0] = 'Default';
$order[$iso_i] = 'ISO2004';
$order[$vert_i] = 'Vertical';
$order[$isovert_i] = 'ISO2004/Vertical';


GetOptions(
  "lang=s"   => \$opt_lang,
  "version"  => \$opt_version,
  "help|?|h" => \$opt_help) or pod2usage(1);

if (win32()) {
  pod2usage(-exitstatus => 0,
            -verbose => 2,
            -noperldoc => 1,
            -output  => \*STDOUT) if $opt_help;
} else {
  pod2usage(-exitstatus => 0, -verbose => 2, -file => $0) if $opt_help;
}

if ($opt_version) {
  print "$prg $version\n";
  exit 0;
}

if ($opt_lang ne "en") {
  print STDERR "$prg: languages other than en currently not implemented.\n";
}

&main();

sub main {
  #
  #
  $mw = MainWindow->new;
  $mw->title("Kanji Fontmap Creator");
  $mw->optionAdd("*Button.Relief", "ridge", 20);
  my $tf = $mw->Frame;
  my $nb = $mw->NoteBook;
  my $bf = $mw->Frame;
  #
  # top frame
  #
  my $name_label = $tf->Label(-text => "Group name:");
  my $name_entry = $tf->Entry(-width => 30, -textvariable => \$group_name,
    -validate => "all", -validatecommand => \&validate_group_name);
  my $opt_label  = $tf->Label(-text => "Options:");
  my $opt_vert   = $tf->Checkbutton(-text => "separate vertical fonts",
    -variable => \$do_vertical);
  my $opt_iso    = $tf->Checkbutton(-text => "separate ISO 2004 support",
    -variable => \$do_iso2004 );
  my $opt_otf    = $tf->Checkbutton(-text => "OTF support",
    -variable => \$do_otf);
  #
  # pack the stuff
  $name_label->grid(-row => 0, -column => 0, -sticky => "e");
  $name_entry->grid(-row => 0, -column => 1, -sticky => "w");
  $opt_label->grid(-row => 1, -column => 0, -sticky => "e");
  $opt_otf->grid(-row => 1, -column => 1, -sticky => "w");
  $opt_iso->grid(-column => 1, -sticky => "w");
  $opt_vert->grid(-column => 1, -sticky => "w");
  #
  # notebook part
  my @p;
  for my $i (0..$#order) {
    $p[$i] = $nb->add($order[$i], -label => $order[$i],
      -state => ($i > 0 ? "disabled" : "normal"));
  }
  #
  # pack outer window
  $tf->pack(-expand => 1, -fill => 'x', -padx => '4m', -pady => '4m');
  $nb->pack(-expand => 1, -fill => 'both', -padx => '4m');
  $bf->pack(-expand => 1, -fill => 'x', -padx => '4m', -pady => '4m');
  #
  # 
  my @l_mincho; my @l_gothic;
  my @l_regular;
  my @l_bold;
  my @l_heavy;
  my @l_light;
  my @l_maru;
  my @e_mincho_regular; my @e_gothic_regular;
  my @e_mincho_bold; my @e_gothic_bold;
  my @e_gothic_heavy;
  my @e_gothic_maru;
  my @e_mincho_light;
  my $ew = 20;
  for my $i (0..$#order) {
    $l_mincho[$i] = $p[$i]->Label(-text => "Mincho");
    $l_gothic[$i] = $p[$i]->Label(-text => "Gothic");
    #
    $l_regular[$i] = $p[$i]->Label(-text => "Regular");
    $e_mincho_regular[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_mincho_regular[$i]);
    $e_gothic_regular[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_gothic_regular[$i]);
    #
    $l_bold[$i] = $p[$i]->Label(-text => "Bold", -state => "disabled");
    $e_mincho_bold[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_mincho_bold[$i],
      -state => "disabled", -relief => "flat");
    $e_gothic_bold[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_gothic_bold[$i],
      -state => "disabled", -relief => "flat");
    #
    $l_heavy[$i] = $p[$i]->Label(-text => "Heavy", -state => "disabled");
    $l_light[$i] = $p[$i]->Label(-text => "Light", -state => "disabled");
    $l_maru[$i] =  $p[$i]->Label(-text => "Maru",  -state => "disabled");
    $e_gothic_heavy[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_gothic_heavy[$i],
      -state => "disabled", -relief => "flat");
    $e_gothic_maru[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_gothic_maru[$i],
      -state => "disabled", -relief => "flat");
    $e_mincho_light[$i] = $p[$i]->Entry(-width => $ew,
      -textvariable => \$f_mincho_light[$i],
      -state => "disabled", -relief => "flat");
    #
    # grid the whole stuff
    $l_mincho[$i]->grid(-row => 0, -column => 1);
    $l_gothic[$i]->grid(-row => 0, -column => 2);
    #
    $l_regular[$i]->grid(-row => 1, -column => 0,  -sticky => "e");
    $e_mincho_regular[$i]->grid(-row => 1, -column => 1);
    $e_gothic_regular[$i]->grid(-row => 1, -column => 2);
    #
    $l_bold[$i]->grid(-row => 3, -column => 0,  -sticky => "e");
    $e_mincho_bold[$i]->grid(-row => 3, -column => 1);
    $e_gothic_bold[$i]->grid(-row => 3, -column => 2);
    #
    $l_heavy[$i]->grid(-row => 4, -column => 0,  -sticky => "e");
    $e_gothic_heavy[$i]->grid(-row => 4, -column => 1);
    $l_maru[$i]->grid(-row => 5, -column => 0,  -sticky => "e");
    $e_gothic_maru[$i]->grid(-row => 5, -column => 2);
    $l_light[$i]->grid(-row => 6, -column => 0,  -sticky => "e");
    $e_mincho_light[$i]->grid(-row => 6, -column => 2);
  }
  #
  # Button frame
  $b_save = $bf->Button(-text => "Save");

  #
  # Actions:
  #
  # activate tabs when options are selected
  $opt_vert->configure(-command => sub { 
      if (!$do_vertical && ($nb->raised() =~ m/Vertical/)) {
        $nb->raise("Default");
      }
      $nb->pageconfigure("Vertical", 
        -state => ($do_vertical ? "normal" : "disabled"));
      $nb->pageconfigure("ISO2004/Vertical",
        -state => (($do_vertical & $do_iso2004) ? "normal" : "disabled"))
    });
  $opt_iso->configure(-command => sub { 
      if (!$do_iso2004 && ($nb->raised() =~ m/ISO2004/)) {
        $nb->raise("Default");
      }
      $nb->pageconfigure("ISO2004",
        -state => ($do_iso2004 ? "normal" : "disabled"));
      $nb->pageconfigure("ISO2004/Vertical",
        -state => (($do_vertical & $do_iso2004) ? "normal" : "disabled")) 
    });

  # activate lower part for when otf is selected
  $opt_otf->configure(-command => sub {
    for my $i (0..$#order) {
      $l_light[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"));
      $e_mincho_light[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"),
        -relief => ($do_otf ? "sunken" : "flat"));
      #
      $l_bold[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"));
      $e_mincho_bold[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"),
        -relief => ($do_otf ? "sunken" : "flat"));
      $e_gothic_bold[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"),
        -relief => ($do_otf ? "sunken" : "flat"));
      #
      $l_heavy[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"));
      $l_maru[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"));
      $e_gothic_maru[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"),
        -relief => ($do_otf ? "sunken" : "flat"));
      $e_gothic_heavy[$i]->configure(
        -state => ($do_otf ? "normal" : "disabled"),
        -relief => ($do_otf ? "sunken" : "flat"));
    }
  });
  #
  #
  $b_save->configure(-command => \&export_font_maps, -state => "disabled");
  $b_save->pack;

  Tk::MainLoop();
}

sub validate_group_name {
  my ($new_val, undef, $old_val) = @_;
  $b_save->configure(-state => ($new_val eq "" ? "disabled" : "normal"));
  return 1;
}

sub addgroup {
  my ($str, $fref, $i_a, $i_b, @entries) = @_;
  my $do = 1;
  while (@entries) {
    my $tfm = shift @entries;
    my $enc = shift @entries;
    addlines($str, $tfm, $enc, ($do ? $fref->[$i_a] : $fref->[$i_b]));
    $do = !$do;
  } 
}

sub addlines {
  my ($strref, @entries) = @_;
  while (@entries) {
    my $tfm = shift @entries;
    my $enc = shift @entries;
    my $fn  = shift @entries;
    if (defined($fn)) {
      $$strref .= "$tfm $enc $fn\n";
    } else {
      print STDERR "target file for $tfm $enc not defined!\n";
    }
  }
}

sub export_font_maps {
  if ($group_name eq "") {
    print STDERR "That should not happen!\n";
    exit 1;
  }

  # indirections
  my $ii = ($do_iso2004  ?  $iso_i  : 0);
  my $vi = ($do_vertical ?  $vert_i : 0);
  my $ivi = (($do_vertical && $do_vertical) ?  $isovert_i : 0);
  #
  
  my ($ptexlines, $ptex04lines, $uptexlines, $uptex04lines);
  my ($otflines, $otfuplines);
  addlines(\$ptexlines, 
    'rml', 'H', $f_mincho_regular[0],
    'rmlv','V', $f_mincho_regular[$vi],
    'gbm', 'H', $f_gothic_regular[0],
    'gbmv','V', $f_gothic_regular[$vi]);
  addlines(\$ptex04lines, 
    'rml', 'H', $f_mincho_regular[$ii],
    'rmlv','V', $f_mincho_regular[$ivi],
    'gbm', 'H', $f_gothic_regular[$ii],
    'gbmv','V', $f_gothic_regular[$ivi]);
  addlines(\$uptexlines,
    'urml',     'UniJIS-UTF16-H', $f_mincho_regular[0],
    'urmlv',    'UniJIS-UTF16-V', $f_mincho_regular[$vi],
    'ugbm',     'UniJIS-UTF16-H', $f_gothic_regular[0],
    'ugbmv',    'UniJIS-UTF16-V', $f_gothic_regular[$vi],
    'uprml-h',  'UniJIS-UTF16-H', $f_mincho_regular[0],
    'uprml-v',  'UniJIS-UTF16-V', $f_mincho_regular[$vi],
    'upgbm-h',  'UniJIS-UTF16-H', $f_gothic_regular[0],
    'upgbm-v',  'UniJIS-UTF16-V', $f_gothic_regular[$vi],
    'uprml-hq', 'UniJIS-UCS2-H',  $f_mincho_regular[0],
    'upgbm-hq', 'UniJIS-UCS2-H',  $f_gothic_regular[0]);
  addlines(\$uptex04lines,
    'urml',     'UniJIS-UTF16-H', $f_mincho_regular[$ii],
    'urmlv',    'UniJIS-UTF16-V', $f_mincho_regular[$ivi],
    'ugbm',     'UniJIS-UTF16-H', $f_gothic_regular[$ii],
    'ugbmv',    'UniJIS-UTF16-V', $f_gothic_regular[$ivi],
    'uprml-h',  'UniJIS-UTF16-H', $f_mincho_regular[$ii],
    'uprml-v',  'UniJIS-UTF16-V', $f_mincho_regular[$ivi],
    'upgbm-h',  'UniJIS-UTF16-H', $f_gothic_regular[$ii],
    'upgbm-v',  'UniJIS-UTF16-V', $f_gothic_regular[$ivi],
    'uprml-hq', 'UniJIS-UCS2-H',  $f_mincho_regular[$ii],
    'upgbm-hq', 'UniJIS-UCS2-H',  $f_gothic_regular[$ii]);
 
  
  addlines(\$otflines,
    '%', 'mincho regular', '',
    'otf-ujmr-h', 'UniJIS-UTF16-H', $f_mincho_regular[0],
    'otf-ujmr-v', 'UniJIS-UTF16-V', $f_mincho_regular[$vi],
    'otf-cjmr-h', 'Identity-H',     $f_mincho_regular[0],
    'otf-cjmr-v', 'Identity-V',     $f_mincho_regular[$vi],
    'hminr-h',    'H',              $f_mincho_regular[0],
    'hminr-v',    'V',              $f_mincho_regular[$vi],
    '%', 'gothic regular', '',
    'otf-ujgr-h', 'UniJIS-UTF16-H', $f_gothic_regular[0],
    'otf-ujgr-v', 'UniJIS-UTF16-V', $f_gothic_regular[$vi],
    'otf-cjgr-h', 'Identity-H',     $f_gothic_regular[0],
    'otf-cjgr-v', 'Identity-V',     $f_gothic_regular[$vi],
    'hgothr-h',   'H',              $f_gothic_regular[0],
    'hgothr-v',   'V',              $f_gothic_regular[$vi],
    '%', 'mincho bold', '');
  addgroup(\$otflines, ($do_otf ? \@f_mincho_bold : \@f_mincho_regular),
    0, $vi,
    'otf-ujmb-h', 'UniJIS-UTF16-H',
    'otf-ujmb-v', 'UniJIS-UTF16-V',
    'otf-cjmb-h', 'Identity-H',
    'otf-cjmb-v', 'Identity-V',
    'hminb-h',    'H',
    'hminb-v',    'V');
  addlines(\$otflines, '%', 'gothic bold', '');
  addgroup(\$otflines, ($do_otf ? \@f_gothic_bold : \@f_gothic_regular),
    0, $vi,
    'otf-ujgb-h', 'UniJIS-UTF16-H',
    'otf-ujgb-v', 'UniJIS-UTF16-V',
    'otf-cjgb-h', 'Identity-H',
    'otf-cjgb-v', 'Identity-V',
    'hgothb-h',   'H',
    'hgothb-v',   'V');
  addlines(\$otflines, '%', 'gothic heavy', '');
  addgroup(\$otflines, ($do_otf ? \@f_gothic_heavy : \@f_gothic_regular),
    0, $vi,
    'hgotheb-h', 'H',
    'hgotheb-v', 'V');
  addlines(\$otflines, '%', 'gothic maru', '');
  addgroup(\$otflines, ($do_otf ? \@f_gothic_maru : \@f_gothic_regular),
    0, $vi,
    'otf-ujmgr-h', 'UniJIS-UTF16-H',
    'otf-ujmgr-v', 'UniJIS-UTF16-V',
    'otf-cjmgr-h', 'Identity-H',
    'otf-cjmgr-v', 'Identity-V',
    'hmgothr-h',   'H',
    'hmgothr-v',   'V');
  addlines(\$otflines, '%', 'mincho light', '');
  addgroup(\$otflines, ($do_otf ? \@f_mincho_light : \@f_mincho_regular),
    0, $vi,
    'otf-ujml-h', 'UniJIS-UTF16-H',
    'otf-ujml-v', 'UniJIS-UTF16-V',
    'otf-cjml-h', 'Identity-H',
    'otf-cjml-v', 'Identity-V',
    'hminl-h',    'H',
    'hminl-v',    'V');
  addlines(\$otflines, '%', 'JIS 2004', '',
    'otf-ujmrn-h', 'UniJIS2004-UTF16-H', $f_mincho_regular[$ii],
    'otf-ujmrn-v', 'UniJIS2004-UTF16-V', $f_mincho_regular[$ivi],
    'hminrn-h',    'H',                  $f_mincho_regular[$ii],
    'hminrn-v',    'V',                  $f_mincho_regular[$ivi],
    '%', '', '',
    'otf-ujgrn-h', 'UniJIS2004-UTF16-H', $f_gothic_regular[$ii],
    'otf-ujgrn-v', 'UniJIS2004-UTF16-V', $f_gothic_regular[$ivi],
    'hgothrn-h',   'H'                 , $f_gothic_regular[$ii],
    'hgothrn-v',   'V'                 , $f_gothic_regular[$ivi],
    '%', '', '');
  addgroup(\$otflines, ($do_otf ? \@f_mincho_bold : \@f_mincho_regular),
    $ii, $ivi,
    'otf-ujmbn-h', 'UniJIS2004-UTF16-H',
    'otf-ujmbn-v', 'UniJIS2004-UTF16-V',
    'hminbn-h',    'H',
    'hminbn-v',    'V');
  addlines(\$otflines, '%', '', '');
  addgroup(\$otflines, ($do_otf ? \@f_gothic_bold : \@f_gothic_regular),
    $ii, $ivi,
    'otf-ujgbn-h', 'UniJIS2004-UTF16-H',
    'otf-ujgbn-v', 'UniJIS2004-UTF16-V',
    'hgothbn-h',   'H',
    'hgothbn-v',   'V');
  addlines(\$otflines, '%', '', '');
  addgroup(\$otflines, ($do_otf ? \@f_gothic_heavy : \@f_gothic_regular),
    $ii, $ivi,
    'otf-ujmgrn-h', 'UniJIS2004-UTF16-H',
    'otf-ujmgrn-v', 'UniJIS2004-UTF16-V',
    'hmgothrn-h', 'H',
    'hmgothrn-v', 'V');
  addlines(\$otflines, '%', '', '');
  addgroup(\$otflines, ($do_otf ? \@f_mincho_light : \@f_mincho_regular),
    $ii, $ivi,
    'otf-ujmln-h', 'UniJIS2004-UTF16-H',
    'otf-ujmln-v', 'UniJIS2004-UTF16-V',
    'hminln-h',    'H',
    'hminln-v',    'V');

  addlines(\$otfuplines,
    'uphminr-h',   'UniJIS-UTF16-H', $f_mincho_regular[0],
    'uphminr-v',   'UniJIS-UTF16-V', $f_mincho_regular[$vi],
    'uphgothr-h',  'UniJIS-UTF16-H', $f_gothic_regular[0],
    'uphgothr-v',  'UniJIS-UTF16-V', $f_gothic_regular[$vi]);
  addgroup(\$otfuplines, ($do_otf ? \@f_mincho_bold : \@f_mincho_regular),
    0, $vi,
    'uphminb-h',   'UniJIS-UTF16-H',
    'uphminb-v',   'UniJIS-UTF16-V');
  addgroup(\$otfuplines, ($do_otf ? \@f_gothic_bold : \@f_gothic_regular),
    0, $vi,
    'uphgothb-h',  'UniJIS-UTF16-H',
    'uphgothb-v',  'UniJIS-UTF16-V');
  addgroup(\$otfuplines, ($do_otf ? \@f_gothic_heavy : \@f_gothic_regular),
    0, $vi,
    'uphgotheb-h', 'UniJIS-UTF16-H',
    'uphgotheb-v', 'UniJIS-UTF16-V');
  addgroup(\$otfuplines, ($do_otf ? \@f_gothic_maru : \@f_gothic_regular),
    0, $vi,
    'uphmgothr-h', 'UniJIS-UTF16-H',
    'uphmgothr-v', 'UniJIS-UTF16-V');
  addgroup(\$otfuplines, ($do_otf ? \@f_mincho_light : \@f_mincho_regular),
    0, $vi,
    'uphminl-h',   'UniJIS-UTF16-H',
    'uphminl-v',   'UniJIS-UTF16-V');

  # check that none of the output files are already existing:
  if (-r "ptex-$group_name.map" ||
      -r "ptex-${group_name}-04.map" ||
      -r "uptex-$group_name.map" ||
      -r "uptex-${group_name}-04.map" ||
      -r "otf-$group_name.map" ||
      -r "otf-up-$group_name.map" ||
      -r "$group_name.map" ||
      -r "${group_name}-04.map") {
    print STDERR "Some of the output files already exist in the cwd, aborting!\n";
    exit 1;
  }

  # generate the output files
  open (OUT, ">ptex-$group_name.map") 
    or die("Cannot open ptex-$group_name.map for writing: $!");
  print OUT "% generated by $prg\n$ptexlines\n";
  close(OUT);

  open (OUT, ">ptex-${group_name}-04.map")
    or die("Cannot open ptex-${group_name}-04.map for writing: $!");
  print OUT "% generated by $prg\n$ptex04lines\n";
  close(OUT);

  open (OUT, ">uptex-$group_name.map") 
    or die("Cannot open uptex-$group_name.map for writing: $!");
  print OUT "% generated by $prg\n$uptexlines\n";
  close(OUT);

  open (OUT, ">uptex-${group_name}-04.map")
    or die("Cannot open uptex-${group_name}-04.map for writing: $!");
  print OUT "% generated by $prg\n$uptex04lines\n";
  close(OUT);

  open (OUT, ">otf-$group_name.map") 
    or die("Cannot open otf-$group_name.map for writing: $!");
  print OUT "% generated by $prg\n$otflines\n";
  close(OUT);

  open (OUT, ">otf-up-$group_name.map") 
    or die("Cannot open otf-up-$group_name.map for writing: $!");
  print OUT "% generated by $prg\n$otfuplines\n";
  close(OUT);
 
  open (OUT, ">$group_name.map")
    or die("Cannot open $group_name.map for writing: $!");
  print OUT "% generated by $prg\n%\n% maps for family $group_name\n\n";
  print OUT "% ptex\n$ptexlines\n";
  print OUT "% uptex\n$uptexlines\n";
  print OUT "% otf\n$otflines\n";
  print OUT "% otf-uptex\n$otfuplines\n";
  close(OUT);
 
  open (OUT, ">${group_name}-04.map")
    or die("Cannot open ${group_name}-04.map for writing: $!");
  print OUT "% generated by $prg\n%\n% maps for family $group_name ISO2004\n\n";
  print OUT "% ptex\n$ptex04lines\n";
  print OUT "% uptex\n$uptex04lines\n";
  print OUT "% otf\n$otflines\n";
  print OUT "% otf-uptex\n$otfuplines\n";
  close(OUT);

  my $cwd = cwd();
  
  $mw->Dialog(-title => "Finished",
    -text => "Fontmaps have been created in the $cwd.\nPlease move them to a place where dvipdfmx can find them.",
    -buttons => [ "Finish" ])->Show();
 
  $mw->destroy;
  exit 0;
}


sub win32 { return ($^O =~ /^MSWin/i ? 1 : 0); }

__END__

=head1 NAME

kanji-fontmap-creator - GUI to create map file collections for Kanji fonts

=head1 SYNOPSIS

kanji-fontmap-creator [I<option>]

=head1 DESCRIPTION

Create fontmap families for updmap's C<kanjiEmbed> setting. For details
see the man page of B<updmap>(1) and the web page
L<http://tug.org/texlive/updmap-kanji.html>

=head1 OPTIONS

=over 4

=item B<-version>

Output version information and exit.

=item B<-help>, B<-?>, B<-h>

Display this help and exit.

=item B<-lang> I<llcode>

By default, the GUI tries to deduce your language from the environment
(on Windows via the registry, on Unix via C<LC_MESSAGES>). If that fails
you can select a different language by giving this option with a
language code (based on ISO 639-1).  Currently supported is only
English.

=back

=head1 AUTHORS AND COPYRIGHT

This script and documentation was written by Norbert Preining
and both are licensed under the GNU General Public License Version 2 
or later.

=cut


# vim:set tabstop=2 expandtab: #
