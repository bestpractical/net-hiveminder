#!/usr/bin/env perl
package Net::Hiveminder::Task;
use Moose;
extends 'Net::Jifty::Record';

use Number::RecordLocator;
my $LOCATOR = Number::RecordLocator->new;

sub record_locator {
    my $self = shift;
    return $LOCATOR->encode($self->id);
}

sub priority_word {
    my $self = shift;
    return (undef, qw/lowest low normal high highest/)[$self->priority];
}

# XXX: datetime and timestamp fields should already be DateTime
sub starts_datetime {
    my $self = shift;
    return undef if !$self->starts;
    $self->_interface->load_date($self->starts);
}

sub starts_after {
    my $self = shift;
    my $time = shift || time;

    my $starts = $self->starts_datetime;
    return 0 if !defined($starts);
    return $starts >= $time if blessed($time);
    return $starts->epoch >= $time;
}

sub display {
    my $self = shift;
    my %args = @_;

    my $locator = $self->record_locator;
    my $display;

    if ($self->complete) {
        $display .= '* ';
    }

    my $loc_display = "#$locator";
    if ($args{color}) {
        my $color = $self->priority >= 5 ? "\e[31m" # red
                  : $self->priority == 4 ? "\e[33m" # yellow
                  : $self->priority == 2 ? "\e[36m" # cyan
                  : $self->priority <= 1 ? "\e[34m" # blue
                  : "";
        $loc_display = "$color$loc_display\e[m" if $color;
    }

    if ($args{linkify_locator}) {
        $display .= sprintf '<a href="%s/task/%s">%s</a>: %s',
            $self->_interface->site,
            $locator,
            $loc_display,
            $self->summary;
    }
    else {
        $display .= "$loc_display: " . $self->summary;
    }

    $display .= " [". $self->tags ."]" if $self->tags;
    $display .= " [". $self->due ."]" if $self->due;

    # display start date only if it's in the future
    $display .= " [". $self->starts ."]"
        if $self->starts_after(time);

    $display .= " [priority: " . $self->priority_word . "]"
        if $self->priority != 3;

    my $helper = sub {
        my ($field, $name) = @_;

        my $id = $self->$field
            or return;

        my $email = $self->_interface->email_of($id)
            or return;

        $self->_interface->is_me($email)
            and return;

        $display .= " [$name: $email]";
    };

    $helper->('requestor_id', 'for');
    $helper->('owner_id', 'by');

    return $display;
}

no Moose;

1;

