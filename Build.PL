use strict;

use Module::Build;

require Win32;
unless (Win32::IsWinNT) {
  die "Windows NT (2000/XP/2003/etc) is required!\n";
}

my $build = Module::Build->new
    (
     module_name => 'Log::Dispatch::Win32EventLog',
     license => 'perl',
     requires => {
       'perl'                     => 5.005,
       'base'                     => 0,
       'Params::Validate'         => 0,
       'Log::Dispatch'            => 2.01,
       'Win32'                    => 0,
       'Win32::EventLog'          => 0,
     },
# requires_os: MSWin32
     recommends => {
       'Log::Log4perl'            => 0,
       'Win32::EventLog::Message' => 0,
     },
     build_requires => {
       'Test::More'               => 0,
     },
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>, Arthur Bergman <abergman at cpan.org> and Gunnar Hansson <gunnar at telefonplan.nu>',
);

$build->create_build_script;
