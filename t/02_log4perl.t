#-*- mode: perl;-*-

use strict;

use constant NUM_ROUNDS => 2;

use Test::More tests => 6 + (6*NUM_ROUNDS);

BEGIN {
  ok( Win32::IsWinNT(), "Win32::IsWinNT?" );

  use_ok('Win32::EventLog');
}

ok($Win32::EventLog::GetMessageText = 1,
   "Set Win32::EventLog::GetMessageText");

my $hnd;

sub open_log {
  $hnd = new Win32::EventLog("Win32EventLog Log4perl Test", Win32::NodeName);
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
    print "\x23 WARNING: Unable to read event log";
    return;
  }
}


eval {
  require Log::Log4perl;
  import Log::Log4perl;
};

my $has_it = ($@) ? 0 : 1;

SKIP: {

  skip "Log::Log4perl not found", 3+(6*NUM_ROUNDS)
    unless ($has_it);

  my $config = qq{
log4perl.logger.test               = INFO, EventLog

log4perl.appender.EventLog         = Log::Dispatch::Win32EventLog
log4perl.appender.EventLog.layout  = Log::Log4perl::Layout::SimpleLayout
log4perl.appender.EventLog.source  = Win32EventLog Log4perl Test
log4perl.appender.EventLog.Threshold = INFO
};

  Log::Log4perl::init( \$config );
  my $log = Log::Log4perl->get_logger('test');

  ok( defined $log, "get_logger" );

  open_log();


  my %Events = ( );		# track events that we logged
  my $time   = time();

  # We run multiple rounds because we want to avoid checking passing the
  # tests based on previous run of this script.  That, combined with
  # using the time to differentiate runs, should make sure that we test
  # for each session.

  foreach my $tag (1..NUM_ROUNDS) {

    my $cnt1 = get_number();

    $log->error("error,$tag,$time");
    $Events{"error,$tag,$time"} = 1;

    my $cnt2 = get_number();
    ok( $cnt2 > $cnt1 );

    $log->warn("warning,$tag,$time");
    $Events{"warning,$tag,$time"} = 1;

    $cnt1 = get_number();
    ok( $cnt1 > $cnt2 );

    $log->info("info,$tag,$time");
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
	   ($event->{Source} eq 'Win32EventLog Log4perl Test') ) {
	if ( $3 == $time) {
	  my $key = "$1,$2,$3";
	  ok(delete $Events{$key});
	}

      }
    }
    ok( (keys %Events) == 0 );
  }


  close_log();


};


