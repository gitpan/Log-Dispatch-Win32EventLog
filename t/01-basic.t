#-*- mode: perl;-*-

use strict;

use constant NUM_ROUNDS => 2;

use Test::More tests => 7 + (6*NUM_ROUNDS);

use Win32 0.23;

BEGIN {
#  ok( Win32::IsWinNT(), "Win32::IsWinNT?" );

  use_ok('Win32::EventLog');
  use_ok('Log::Dispatch');
  use_ok('Log::Dispatch::Win32EventLog');
}

ok($Win32::EventLog::GetMessageText = 1,
   "Set Win32::EventLog::GetMessageText");

my $hnd;

sub open_log {
  $hnd = new Win32::EventLog("Application", Win32::NodeName);
}

sub close_log {
  if ($hnd) { $hnd->Close; }
  $hnd = undef;
}

sub get_number {
  my $cnt = -1;
  $hnd->GetNumber($cnt);
  return $cnt;
}

sub get_last_event {
  my $event = { };
  if ($hnd->Read(
    EVENTLOG_BACKWARDS_READ() | 
      EVENTLOG_SEQUENTIAL_READ(), 0, $event)) {
    return $event;
  } else {
    print "\x23 WARNING: Unable to read event log\n";
    return;
  }
}

open_log();

my $dispatch = Log::Dispatch->new;
ok( defined $dispatch, "new Log::Dispatch" );

$dispatch->add( Log::Dispatch::Win32EventLog->new(
  source => 'Win32EventLog test',
  min_level => 0, max_level => 7, name => 'test'
));

my %Events = ( ); # track events that we logged
my $time   = time();

# We run multiple rounds because we want to avoid checking passing the
# tests based on previous run of this script.  That, combined with
# using the time to differentiate runs, should make sure that we test
# for each session.

foreach my $tag (1..NUM_ROUNDS) {

  my $cnt1 = get_number();

  $dispatch->log(level => 'emerg',   message => "emergency,$tag,$time");
  $Events{"emergency,$tag,$time"} = 1;

  my $cnt2 = get_number();
  ok( $cnt2 > $cnt1 );

  $dispatch->log(level => 'warning', message => "warning,$tag,$time");
  $Events{"warning,$tag,$time"} = 1;

  $cnt1 = get_number();
  ok( $cnt1 > $cnt2 );

  $dispatch->log(level =>'info',     message => "info,$tag,$time");
  $Events{"info,$tag,$time"} = 1;

  $cnt2 = get_number();
  ok( $cnt2 > $cnt1 );
}

{
  ok( (keys %Events) == (3*NUM_ROUNDS) );

#  require YAML;

  while ((keys %Events) && (my $event = get_last_event())) {

#    print STDERR YAML->Dump($event);

      my $string = $event->{Strings};

    if ( ($string =~ /(\w+)\,(\d+),(\d+)/) &&
	 ($event->{Source} eq 'Win32EventLog test') ) {
      if( $3 == $time) {
	my $key = "$1,$2,$3";
	ok(delete $Events{$key});
      }
    }

  }
  ok( (keys %Events) == 0 );
}


close_log();
