use strict;
use warnings;

use Test::More tests => 10;

BEGIN { use_ok('Config::Entities') }

use Config::Entities;
use Data::Dumper;
use File::Basename;
use File::Spec;

my $test_dir = dirname( File::Spec->rel2abs($0) );

my ( $entities, $hashref );
ok( $entities = Config::Entities->new(), 'no entities dirs' );

is_deeply(
    Config::Entities->new("$test_dir/local_entities"),
    {   b => {
            d        => 'efg',
            username => undef,
            password => undef
        }
    },
    'local_entity'
);

$entities = Config::Entities->new( "$test_dir/local_entities",
    { properties => { username => 'user', password => 'pass' } } );
is_deeply(
    $entities,
    {   b => {
            d        => 'efg',
            username => 'user',
            password => 'pass'
        }
    },
    'local_entity with properties'
);

$entities = Config::Entities->new( "$test_dir/local_entities",
    { properties_file => "$test_dir/config.pl" } );
is_deeply(
    $entities,
    {   b => {
            d        => 'efg',
            username => 'file_user',
            password => 'file_pass'
        }
    },
    'local_entity with properties file'
);

$entities = Config::Entities->new(
    "$test_dir/local_entities",
    {   properties_file => "$test_dir/config.pl",
        properties      => { username => 'override_user' }
    }
);
is_deeply(
    $entities,
    {   b => {
            d        => 'efg',
            username => 'override_user',
            password => 'file_pass'
        }
    },
    'local_entity with properties file and properties'
);

$entities = Config::Entities->new(
    "$test_dir/entities",
    "$test_dir/local_entities",
    {   properties_file => "$test_dir/config.pl",
        properties      => { username => 'override_user' }
    }
);
is_deeply(
    $entities,
    {   a => 1,
        b => {
            c        => 1,
            d        => 'efg',
            username => 'override_user',
            password => 'file_pass'
        },
        d => {
            e => { f => 1 },
            g => {
                h => 'abc',
                i => 'ghi',
                j => {
                    i => 'ghi',
                    k => { l => { m => 'jkl' } }
                }
            }
        }
    },
    'entities and local_entity with properties file and properties'
);

$entities = Config::Entities->new(
    "$test_dir/entities",
    "$test_dir/local_entities",
    {   properties_file => "$test_dir/config.pl",
        properties      => { username => 'override_user' }
    }
);
is_deeply(
    $entities->get_entity('d.g.j'),
    {   i => 'ghi',
        k => { l => { m => 'jkl' } }
    },
    'get_entity'
);

$entities = Config::Entities->new(
    "$test_dir/entities",
    "$test_dir/local_entities",
    {   properties_file => "$test_dir/config.pl",
        properties      => { username => 'override_user' }
    }
);
$hashref = $entities->fill( 'd.g.j.k.l', { h => undef, i => undef, m => undef }, ancestry => 1 );
is_deeply(
    $hashref,
    {   h => 'abc',
        i => 'ghi',
        m => 'jkl'
    },
    'fill hashref coordinate with ancestry'
);

$entities = Config::Entities->new(
    "$test_dir/entities",
    "$test_dir/local_entities",
    {   properties_file => "$test_dir/config.pl",
        properties      => { username => 'override_user' }
    }
);
$hashref = $entities->fill( 'd.g.j.k.l.m', { h => undef, i => undef }, ancestry => 1 );
is_deeply(
    $hashref,
    {   h => 'abc',
        i => 'ghi'
    },
    'fill non-hashref coordinate with ancestry'
);

