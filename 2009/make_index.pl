#

#  script to generate the TOC for the Geocomp 2009 proceedings

use strict;
use warnings;
use Carp;
use File::Spec;
use Data::Dump;
use Text::CSV_XS;
use HTML::QuickTable;

my $csv = Text::CSV_XS -> new ({binary => 1});

my $csv_file = 'proceedings.csv';
my $pdf_folder = 'PDF';

my $header = <<'END_OF_HEADER'
<HTML>

<HEAD>
<TITLE>GeoComputation 2009</TITLE>
<LINK rel="stylesheet" href="./style.css" type="text/css">
</HEAD>

<BODY>
<CENTER>
<TABLE width=550>
<TR>
<TD colspan=2>

<TABLE width=550 cellspacing=0 cellpadding=0>
<TR>
<TD align=right><IMG  src="./word.gif"></TD> 

<TD ROWSPAN=2><IMG src="./globe.gif"></TD></TR>
<tr><td valign=top><IMG src="./cards.gif"></TD></TR>
<TR>
<TD colspan=2>GeoComputation 2009 Conference Proceedings</TD>
</TR>
</TABLE>

</TD>
</TR>

<TR>
<TD colspan=2>
<P>&nbsp;</P>
<H4>Proceedings of the 10th International Conference on GeoComputation<BR>
University of New South Wales,<br>
Sydney, Australia.<BR>
30 November - 02 December 2009</H4>
<P>
Editors:  Brian G. Lees and Shawn W. Laffan
</p>
<p>
<strong>Citing papers in these proceedings:</strong>
</p>
<p>
Papers from these proceedings should be cited using this format:
</p>
<p>
Carrigan, A., Puotinen, M. & Borah, R. (2009)
Tropical Cyclone Induced Cooling Zones: A Geocomputational Hazard.
In Lees, B.G. & Laffan, S.W. (eds), 10th International Conference on GeoComputation,
UNSW, Sydney, November-December, 2009.
</p>
<P>
<STRONG>Papers were peer reviewed by two independent referees.
</STRONG>
</P>

<H4>Conference sponsors:</h4>
PSMA Australia<br>
Taylor and Francis<br>
GISc Study Group; Institute of Australian Geographers <br>
GISc Study Group, Association of American Geographers <br>
IGU Commission on Geographic Information Science C 04.13 <br>
IGU Commission on Modelling Geographical Systems C 00.18 <br>	  	 
</h4>

<P>&nbsp;</P>

END_OF_HEADER
;


open (my $fh, '<', $csv_file) || croak "Cannot open file $csv_file\n";

my @data;
#my $x = $csv -> getline ($fh);
while (my $line = $csv -> getline ($fh)) {
    push @data, $line;
}

my $status = $csv -> status;
#print Data::Dump::dump (\@data);

#my @file_array = glob (File::Spec->catfile($pdf_folder, '*.pdf'));

#my %file_hash;
#@file_hash{@file_array} = undef;

my @table;
my $csv_header = shift @data;
my $last_type = q{};

foreach my $line (@data) {
    my $authors = $line->[0];
    my $title   = $line->[1];
    my $pdf     = 'PDF/' . $line->[2];
    my $type    = $line->[3];

    if ($type ne $last_type) {
        my $sub_header
            = "<h2>$type</h2>";
        push @table, $sub_header;
        $last_type = $type;
    }
    
    my $html
        = qq{<p><I>$authors</I><br><a target="_blank" href=$pdf>$title</a></p><p>&nbsp;</p>};
    
    push @table, $html;
    
    croak "$pdf\n" if not -e $pdf;
    
}

my $qt = HTML::QuickTable -> new (
    labels  => 0,
    header  => 0,
    #title  => 'Analyses and Indices available in Biodiverse',
    title   => '',
    td      => {valign => 'top'},
    table   => {
        border      => 0,
        cellpadding => '5%'
    },
);

my $table = $qt -> render (\@table);
$table =~ s{Content-type: text/html; charset=iso-8859-1}{}g;

$table =~ s{<td><h2>}{<td colspan=2><h2>};

open (my $out_fh, '>', 'index.html');
print {$out_fh} $header;
print {$out_fh} $table;


