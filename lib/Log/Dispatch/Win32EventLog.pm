package Log::Dispatch::Win32EventLog;

use strict;
use vars qw($VERSION);
$VERSION = 0.02;

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
    $self->{win32_handle} = Win32::EventLog->new($self->{win32_source}) || die "Could not instaniate the event application";;

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
	EventType => $level,
	Strings => $params{message} . "\0",
    });
}


1;
__END__

=head1 NAME

Log::Dispatch::Win32EventLog - Class for logging to the Win32 Eventlog

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

=head1 METHODS

=over 4

=item new

  $log = Log::Dispatch::Win32EventLog->new(%params);

This method takes a hash of parameters. The following options are valid:

=item -- name, min_level, max_level, callbacks

Same as various Log::Dispatch::* classes.

=item -- source

This will be the source that the event is recorded from.

=item log_message

inherited from Log::Dispatch::Output.

=back

=head1 AUTHOR

Arthur Bergman E<lt>abergman@cpan.orgE<gt>

Gunnar Hansson E<lt>gunnar@telefonplan.nuE<gt>

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 SEE ALSO

L<Log::Dispatch>, L<Win32::EventLog>

=cut
