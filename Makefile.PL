use 5.008001;
use ExtUtils::MakeMaker;

## look for previously installed version
COMPAT: {
    ## FIXME: less lazy would mean checking the version
    eval { chdir "/"; require "WWW::Twilio::API"; };
    unless( $@ ) {
        warn <<'_COMPAT_';
I see you have previously installed WWW::Twilio::API. Be warned that
if the previously installed version is 0.14 or earlier, the default
Twilio API has changed from 2008-08-01 to 2010-04-01. It's likely your
API calls will not work without some changes to your code if you
upgrade. See the documentation for this module under "COMPATIBILITY
NOTICE" for details and recommendations.
_COMPAT_
    }
}

WriteMakefile(
    NAME              => 'WWW::Twilio::API',
    VERSION_FROM      => 'lib/WWW/Twilio/API.pm',
    PREREQ_PM         => { Crypt::SSLeay  => 0.51,
                           LWP::UserAgent => 2.030,
                           URI::Escape    => 3.28, },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/WWW/Twilio/API.pm', # retrieve abstract from module
       AUTHOR         => 'Scott Wiersdorf <scott@perlcode.org>') : ()),
);
