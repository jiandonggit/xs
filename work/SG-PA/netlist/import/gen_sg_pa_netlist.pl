#!/usr/bin/perl -w 

use Data::Dumper ;
use strict ;
use Getopt::Long ;
use Env;
use Cwd qw(abs_path) ;

my $opts = {
    work => "template" ,
    top => "chip_top" ,
    filelist => "filelist.f",
    liblist => "lib.f"
} ;

GetOptions (
    $opts,
    'top=s',
    'work=s',
    'fsdb=s',
    'startime=s',
    'endtime=s',
    'filelist=s',
    'liblist=s',
    'blackbox=s',
    'spef=s',
    'overwrite'
) ;

print Dumper($opts) . "\n" ;

if ( -d $opts->{work} ) {
    if ($opts->{overwrite} ) { 
        system_cmd("/bin/rm -rf $opts->{work}/{results,WORK,$opts->{top}*}") ;
    }
    else {
        die "$opts->{work} already exists" ;
    }
}

check_file( $opts->{fsdb}) ;
check_file( $opts->{filelist}) ;
check_file( $opts->{liblist}) ;

if ( ! -f $opts->{fsdb} ) {
    die "no such file : $opts->{fsdb}\n" ;
}

system_cmd( "mkdir -p $opts->{work}") ;
#system_cmd( "cp $SPYGLASS_POWERKIT_DIR/power_netlist_files/create_rtl_setup.cs $opts->{work}/" ) ;
system_cmd( "cp $SPYGLASS_POWERKIT_DIR/power_netlist_files/create_netlist_setup.cs $opts->{work}/" ) ;

my $cmd = "sed -r " ;
$cmd .= " -e 's#^(set MODULE =).*#\\1 $opts->{top}#' " ;
$cmd .= " -e 's#^(set PROJECT_DIR_PATH =).*#\\1 ./#' " ;
$cmd .= " -e 's#^(set RESULT_DIR =).*#\\1 result#' " ;
$cmd .= " -e 's#^(set NL_SRC_FL =).*#\\1 $opts->{filelist}#' ";
$cmd .= " -e 's#^(set TECH_LIB_FL =).*#\\1 $opts->{liblist}#' " ;
$cmd .= " -e 's#^(set NL_SIM_FORMAT =).*#\\1 fsdb#' " ;
$cmd .= " -e 's#^(set NL_SIM_FILE =).*#\\1 $opts->{fsdb}#' " ;
$cmd .= " -e 's#^(set NL_SPEF_FILE =).*#\\1 $opts->{spef}#' " if $opts->{spef} ;
$cmd .= " -i $opts->{work}/create_netlist_setup.csh" ;
system_cmd( $cmd ) ;
system_cmd("cd $opts->{work} && csh -f create_netlist_setup.csh") ;

# activity_data
if ( $opts->{startime} ) {
    system_cmd("sed -e 's#^\\s*activity_data .*#& -starttime $opts->{startime}#' -i $opts->{work}/$opts->{top}_netlist.sgdc" ) ;
}
if ( $opts->{endtime} ) {
    system_cmd("sed -e 's#^\\s*activity_data .*#& -endtime $opts->{endtime}#' -i $opts->{work}/$opts->{top}_netlist.sgdc" ) ;
}

# blackbox
if ( $opts->{blackbox} ) {
    system_cmd("sed -e '\$r$opts->{blackbox}'  -i $opts->{work}/$opts->{top}_netlist.prj" ) ;
}

# run
system_cmd("mv $opts->{work}/Makefile{.netlist,}") ;
#system_cmd("make -C $opts->{work} 48") ;
#

sub system_cmd{
    my $cmd = shift ;
    print "=== $cmd\n" ;
    system ("$cmd") ;
}

sub check_file {
    my $file = shift ;
    if ( ! -e $file ) { 
        die "No such file : $file\n"
    }
}











