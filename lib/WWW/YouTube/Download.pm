package WWW::YouTube::Download;

use strict;
use warnings;
use Carp;
no Carp::Assert;
use LWP::UserAgent;
use URI::Escape;

require Exporter;

our @ISA = qw(Exporter);

our %EXPORT_TAGS = ( 'all' => [ qw(
    get_id  save
) ] );

our @EXPORT_OK = ( @{ $EXPORT_TAGS{'all'} } );

our @EXPORT = qw(
);

our $VERSION = '0.02';
our $IS_RIOT = 0;

my $BASE_URL         = "http://www.youtube.com/";
my $INFO_SCRIPT_NAME = "get_video_info";
my $GET_SCRIPT_NAME  = "get_video.php";
my $ID_LIKE          = "[-_\\d\\w]{11}";
my @INVALID_CHARS    = qw(
    \\\\ / : * " ? < > |
);

my $ua = LWP::UserAgent->new();
$ua->timeout(30);

=head1 NAME

WWW::YouTube::Download - Get flv video from YouTube

=head1 SYNOPSIS

  use WWW::YouTube::Download qw( get_id save );
  my $url = "http://www.youtube.com/watch?v=xxxxxxxxxxx";
  my $id  = get_id($url);
  my $saved_name = save($id);
  # Specify name of video file.
  save($id, "video.flv");

  # For debug option.
  $WWW::YouTube::Download::IS_RIOT = 1;

=head1 DESCRIPTION

This module allows you to download vide from YouTube.

ID is necessary to download the video.
The ID can find from URL of video's link.

The URL of YouTube is "http://www.youtube.com/".

=head2 EXPORT

None by default.

=over

=item get_id("http://www.youtube.com/watch?v=xxxxxxxxxxx")

This function parses URL and returns ID.

=cut

sub get_id {
    my $url = shift;
    if (not defined $url) {
        carp "URL was not found.";
        return;
    }

    if ($url =~ m{ v= ($ID_LIKE) }msx) {
        my $id = $1;
        return $id;
    }
    elsif ($url =~ m{\A \s* ($ID_LIKE) \s* \z}msx) {
        my $id = $1;
        return $id;
    }
    else {
        return;
    }
}

sub _is_id_valid {
    my $id = shift;

    if ($id =~ m{\A $ID_LIKE \z}msx) {
        return 1;
    }
    else {
        return;
    }
}

=item save($id)

This function saves the video.
Returns file name that was saved.

If second parameter is passed, it is used to saving file name.

=cut

sub save {
    my ($id, $filename) = @_;
    if (not defined $id) {
        carp "ID was not found.";
        return;
    }
    elsif (not _is_id_valid($id)) {
        $id = get_id($id);
        unless ($id) {
            carp "ID is invalid.";
            return;
        }
    }
    if (defined $filename) {
        my $new_name = _validate_file_name($filename);

        if ($filename ne $new_name) {
            $filename = $new_name;
            warn "The file name($filename) was replaced.\n",
                "That was named ($new_name).\n";
        }

        if (-e $filename) {
            warn "The file name($filename) already exists.\n";
            return;
        }
    }

    my %params = _get_informations($id);
    return
        unless %params;

    my $url = $BASE_URL . $GET_SCRIPT_NAME . "?"
        . "video_id=" . $params{video_id} . "&t=" . $params{token};

    unless ($filename) {
        $filename = _validate_file_name($params{title}.".flv");
    }
    if (-e $filename) {
        warn "The file name($filename) already exists.\n";
        return;
    }

    warn "The file name was set to $filename.\n"
        if $IS_RIOT;

    warn "Start downloading.\n"
        if $IS_RIOT;

    my $res = $ua->get($url, 
        ":content_file" => $filename,
    );

    if (not $res->is_success()) {
        warn "Could not get video that has video_id=", $params{video_id}, "\n"
            ,"(", $res->status_line(), ")\n";
        return;
    }
    elsif (!-e $filename) {
        warn "Failed saving.";
        return;
    }
    warn "Got video that was named: ($filename).\n"
        if $IS_RIOT;

    return $filename;
}

sub _get_informations {
    my $id = shift;
    assert( defined $id )
        if DEBUG;
    assert( _is_id_valid($id) )
        if DEBUG;

    my $url = $BASE_URL . $INFO_SCRIPT_NAME . "?"
        . "video_id=" . $id;

    warn "Start getting informations.\n"
        if $IS_RIOT;

    my $res = $ua->get($url);

    unless ($res->is_success()) {
        warn "Could not get informations that is video_id=", $id, "\n"
            , "(", $res->status_line(), ")\n";
        return;
    }

    my %params = ();

    ADD_PARAM_IF_EQUAL_EXISTS:
    foreach my $element ( split("[;&]", $res->content()) ) {
        next ADD_PARAM_IF_EQUAL_EXISTS
            unless $element =~ m{ [=] }msx;
            
        my ($key, $value) = split "[=]", $element;
        $params{$key} = $value;
    }

    warn "Could not get title.\n"
        unless $params{title};

    $params{title} = uri_unescape($params{title});
    warn "The title is: ($params{title}).\n"
        if $IS_RIOT;

    unless (exists $params{token} and defined $params{token}) {
        warn "Could not get token from video_id=".$id;
        return;
    }

    warn "Got informations.\n"
        if $IS_RIOT;

    return %params;
}

sub _validate_file_name {
    my $name = shift;
    assert( defined $name )
        if DEBUG;

    ERASE_INVALID_CHARACTERS:
    foreach my $char (@INVALID_CHARS) {
        $name =~ s{[$char]}{}gmsx;
    }

    return $name;
}

=back

=head1 SEE ALSO

=head1 AUTHOR

Kuniyoshi Kouji, E<lt>kuniyoshi.kouji@indigo.plala.or.jpE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2009 by Kuniyoshi Kouji

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.0 or,
at your option, any later version of Perl 5 you may have available.

=cut
1;

