package Log::Dispatch::Win32EventLog;

use strict;
# use warnings;
use vars qw($VERSION);
$VERSION = '0.03_01';

$VERSION = eval $VERSION;

use Log::Dispatch 2.01;
use base qw(Log::Dispatch::Output);

use Win32::EventLog;

use Params::Validate qw(validate SCALAR);
Params::Validate::validation_options( allow_extra => 1);

sub new {
    my $proto = shift;
    my $class = ref $proto || $proto;

    my %params = validate(@_, { source => SCALAR });

    my $self = bless {}, $class;
    $self->_basic_init(%params);
    
    $self->{"win32_source"} = $params{source};
    if ($self->{"win32_source"} =~ /[\\]/) {
      die "Invalid characters in source";
    }
    $self->{win32_handle} = Win32::EventLog->new(
      "Application", Win32::NodeName
    ) or die "Could not instaniate the event application";;

    return $self;
}

sub log_message {
    my $self = shift;
    my %params = @_;

    my $level = $self->_level_as_number($params{level});
    
    if($level > 3) {
	$level = EVENTLOG_ERROR_TYPE;
    } elsif($level > 2) {
	$level = EVENTLOG_WARNING_TYPE;
    } else {
	$level = EVENTLOG_INFORMATION_TYPE;
    }
    $self->{win32_handle}->Report( {
	Computer  => Win32::NodeName,
        EventID   => 0,
        Category  => 0,
        Source    => $self->{"win32_source"},
	EventType => $level,
	Strings   => $params{message} . "\0",
        Data      => "",
    });
}


1;
__END__

=head1 NAME

Log::Dispatch::Win32EventLog - Class for logging to the Windows NT Event Log

=head1 SYNOPSIS

  use Log::Dispatch::Win32EventLog;

  my $log = Log::Dispatch::Win32EventLog->new(
      name       => 'myname'
      min_level  => 'info',
      source     => 'My App'
  );

  $log->log(level => 'emergency', messsage => 'something BAD happened');

=head1 DESCRIPTION

Log::Dispatch::Win32EventLog is a subclass of Log::Dispatch::Output, which
inserts logging output into the windows event registry.

=head2 METHODS

=over

=item new

  $log = Log::Dispatch::Win32EventLog->new(%params);

This method takes a hash of parameters. The following options are valid:

=item name

=item min_level

=item max_level

=item callbacks

Same as various Log::Dispatch::* classes.

=item source

This will be the source that the event is recorded from.  Usually this
is the name of your application.

The source should not contain any backslash characters.

=item log_message

inherited from Log::Dispatch::Output.

=back

=head1 OTHER TOPICS

=head1 Using with Log4perl

This module can be used as a L<Log::Log4perl> appender.  The
configuration file should have the following:

  log4perl.appender.EventLog         = Log::Dispatch::Win32EventLog
  log4perl.appender.EventLog.layout  = Log::Log4perl::Layout::SimpleLayout
  log4perl.appender.EventLog.source  = MySourceName
  log4perl.appender.EventLog.Threshold = INFO

Replace MySourceName with the source name of your application.

=head1 SEE ALSO

L<Log::Dispatch>, L<Win32::EventLog>, L<Log::Log4perl>

=head2 Related Modules

L<Win32::EventLog::Carp> traps warn and die signals and sends them to
the NT event log.

=head1 AUTHOR

Robert Rothenberg E<lt>rrwo at cpan.orgE<gt>

Arthur Bergman E<lt>abergman at cpan.orgE<gt>

Gunnar Hansson E<lt>gunnar at telefonplan.nuE<gt>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
