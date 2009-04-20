use inc::Module::Install;

name            'Net-Hiveminder';
all_from        'lib/Net/Hiveminder.pm';

requires        'DateTime';
requires        'Moose';
requires        'Net::Jifty' => '0.06';
requires        'Number::RecordLocator';

features(
    'commandline tool' => [
        -default => 1,
        requires('Term::Encoding'),
     ],
    'comment on tasks' => [
        -default => 1,
        requires        'Email::Simple', 
        'Email::Simple::Creator'
    ],
);


install_script "bin/hm";
install_script "bin/hm-$_"
    for qw/braindump create done sync todo/;

recursive_author_tests 'xt';

auto_install;
sign;
WriteAll;


