use 5.006;
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'googlesearch',
    AUTHOR              => q{Daniel Torres <daniel.torres@owasp.org>},
    VERSION_FROM        => 'lib/googlesearch.pm',
    ABSTRACT_FROM       => 'lib/googlesearch.pm',
    ($ExtUtils::MakeMaker::VERSION >= 6.3002
      ? ('LICENSE'=> 'perl')
      : ()),
    PL_FILES            => {},
    PREREQ_PM => {
        'URI::Escape' => 0,
        'HTML::TokeParser' => 0,
        'HTML::Entities' => 0,
        'Regexp::Common' => 0,
        'HTTP::Cookies' => 0,
        'HTML::Scrubber' => 0,
        'HTML::TreeBuilder' => 0,
        'LWP::UserAgent' => 0,
        'Moose' => 0,
    },
    dist                => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean               => { FILES => 'googlesearch-*' },
);
