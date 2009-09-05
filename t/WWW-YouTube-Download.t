use strict;
use warnings;
use Test::More tests => 16;


BEGIN { use_ok('WWW::YouTube::Download', qw(get_id save)) };

my $tname;

##########
$tname = "Version";
##########
my $wish = "0.02";
is( $WWW::YouTube::Download::VERSION, $wish, $tname );


##########
$tname = "IS_RIOT - Can set?";
##########
$wish = $WWW::YouTube::Download::IS_RIOT;
$wish = $wish ? 0 : 1;
$WWW::YouTube::Download::IS_RIOT = $wish;
is( $WWW::YouTube::Download::IS_RIOT, $wish, $tname );
$WWW::YouTube::Download::IS_RIOT = 0;


##########
$tname = "get_id - Valid case.";
##########
my $url  = "http://www.youtube.com/watch?v=GNKPzQPzTSQ";
$wish    = "GNKPzQPzTSQ";
my $id   = get_id($url);
is( $id, $wish, $tname );
$url = "http://www.youtube.com/watch?v=GNKPzQPzTSQ&some=thing";
is( get_id($url), $wish, $tname );
$url = "http://www.youtube.com/watch?some=thing&v=GNKPzQPzTSQ&any=thing";
is( get_id($url), $wish, $tname );
$url = "http://www.youtube.com/watch?some=thing;v=GNKPzQPzTSQ;any=thing";
is( get_id($url), $wish, $tname );
$url = "http://www.youtube.com/watch?v=GNKPzQPzTSQ;some=thing";
is( get_id($url), $wish, $tname );

##########
$tname = "get_id - Invalid case.";
##########
$url  = "http://www.youtube.com/watch?v=GNKPzQPzTS";
$wish = undef;
$id   = get_id($url);
is( $id, $wish, $tname );
$url  = "http://www.youtube.com/watch?v=GNKPzQPzTS&some=thing";
is( get_id($url), $wish, $tname );
$url  = "http://www.youtube.com/watch?v=GNKPzQPzTS;some=thing";
is( get_id($url), $wish, $tname );
$url  = "http://www.youtube.com/watch?video_id=GNKPzQPzTSQ;some=thing";
is( get_id($url), $wish, $tname );
$url  = "http://www.youtube.com/watch?video_id=GNKPzQPzTSQ";
is( get_id($url), $wish, $tname );


SKIP: {
    skip "This takes time too much.", 3;

##########
$tname = "save - Basic.";
##########
$id     = "hSmvHbq_cKA";
$wish   = "(MAD)+[アイドルマスターXENOGLOSSIA]+機動戦士ゼノグラSEED.flv";
my $res = save($id);
is( $res, $wish, $tname );
ok( -e $res, $tname );
unlink $res;
ok( !-e $res, $tname );

}

