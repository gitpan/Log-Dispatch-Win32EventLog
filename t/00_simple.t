# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..3\n"; }
END {print "not ok 1\n" unless $main::loaded;}

use strict;
#$^W = 1;

use Log::Dispatch;

use Log::Dispatch::Win32EventLog;


$main::loaded = 1;
result($main::loaded);

my $dispatch = Log::Dispatch->new;
result( defined $dispatch, "Couldn't create Log::Dispatch object\n" );

$dispatch->add( Log::Dispatch::Win32EventLog->new(source => 'Win32Event test', min_level => 0, max_level => 7, name => 'test'));

$dispatch->log(level => 'emerg', message => "emergency");
$dispatch->log(level => 'warning', message => "warning");
$dispatch->log(level =>'info', message => "info");


print "ok 3\n";

sub fake_test
{
    my ($x, $pm) = @_;

    warn "Skipping $x test", ($x > 1 ? 's' : ''), " for $pm\n";
    result($_) foreach 1 .. $x;
}


sub result
{
    my $ok = !!shift;
    use vars qw($TESTNUM);
    $TESTNUM++;
    print "not "x!$ok, "ok $TESTNUM\n";
    print @_ if !$ok;
}


