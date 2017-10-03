use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME             => 'linkedin',
    AUTHOR           => q{Daniel Torres <daniel.torres@owasp.org>},
    VERSION_FROM     => 'lib/linkedin.pm',
    ABSTRACT_FROM    => 'lib/linkedin.pm',
    LICENSE          => 'artistic_2',
    PL_FILES         => {},
    MIN_PERL_VERSION => 5.006,
    CONFIGURE_REQUIRES => {
        'ExtUtils::MakeMaker' => 0,
    },
    BUILD_REQUIRES => {
        'Test::More' => 0,
    },
    PREREQ_PM => {
        'Moose'              => 1.0,
        'LWP::UserAgent'              => 1.0,
        'HTTP::Cookies'              => 1.0,
        'JSON'              => 1.0,
        'URI::Escape'              => 1.0,
        'HTTP::Request;'              => 1.0,
        'HTTP::Response'              => 1.0,
        'Net::SSL'              => 1.0,
        'List::Util'              => 1.0,
        'Time::HiRes'              => 1.0,
        'MIME::Base64::Perl'              => 1.0,
        'POSIX'              => 1.0,
        'HTML::Entities'              => 1.0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => 'linkedin-*' },
);
