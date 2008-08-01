use inc::Module::Install;

name            'Net-Hiveminder';
all_from        'lib/Net/Hiveminder.pm';

requires        'Net::Jifty' => '0.06';
requires        'Number::RecordLocator';

features(
    'comment on tasks' => [
        -default => 1,
        requires('Email::Simple::Creator'),
    ],
);

build_requires  'Test::More';

install_script "bin/hm";
install_script "bin/hm-$_"
    for qw/braindump create done sync todo/;

auto_install;
WriteAll;


