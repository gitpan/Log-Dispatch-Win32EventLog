#-*- mode: perl;-*-

use strict;

use Test::More tests => 6;
use Test::Warn;

BEGIN {
  ok( Win32::IsWinNT(), "Win32::IsWinNT?" );

  use_ok('Win32::EventLog');
  use_ok('Log::Dispatch');
  use_ok('Log::Dispatch::Win32EventLog');
}

eval {
  require Win32::EventLog::Message;
  import Win32::EventLog::Message;
};

my $has_it = ($@) ? 0 : 1;

SKIP: {

  skip "Win32::EventLog::Message not found", 2
    unless ($has_it);

  my $dispatch = Log::Dispatch->new;
  ok( defined $dispatch, "new Log::Dispatch" );

  warning_like {
    $dispatch->add( Log::Dispatch::Win32EventLog->new(
      source    => 'Win32EventLog RegSrc Test',
      register  => 'NonExistentBogusUnrealLog',
      min_level => 0, max_level => 7, name => 'test'
    ));
  } qr/Unable to register source to log NonExistentBogusUnrealLog: Invalid log/, "Should fail in fake log";


}
