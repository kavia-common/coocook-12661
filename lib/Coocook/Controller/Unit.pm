package Coocook::Controller::Unit;

use utf8;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
use Scalar::Util qw( looks_like_number weaken );

BEGIN { extends 'Coocook::Controller' }

=head1 NAME

Coocook::Controller::Unit - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=head2 index

=cut

sub index : GET HEAD Chained('/project/base') PathPart('units') Args(0)
  RequiresCapability('view_project') {
    my ( $self, $c ) = @_;

    my %units_in_use;

    {
        my @resultsets = (
            $c->project->units->search_related('articles_units'),
            $c->project->purchase_lists->search_related('items'),
            $c->project->dishes->search_related('ingredients'),
            $c->project->recipes->search_related('ingredients'),
        );

        for my $resultset (@resultsets) {
            my $ids = $resultset->get_column( { distinct => 'unit_id' } );

            @units_in_use{ $ids->all } = ();    # set all keys to undef
        }
    }

    my @units;

    {
        my $action = $self->action_for('delete');

        my $units = $c->project->units->search( undef, { order_by => 'long_name' } );

        while ( my $unit = $units->next ) {
            push @units,
              my $u = $unit->as_hashref( url => $c->project_uri( $self->action_for('edit'), $unit->id ) );

            # add delete_url to deletable units
            exists $units_in_use{ $unit->id }                                 # in use, for ingredient
              or $u->{delete_url} = $c->project_uri( $action, $unit->id );    # can be deleted
        }
    }

    {
        my %units            = map { $_->{id} => $_ } @units;
        my $unit_conversions = $c->project->unit_conversions->hri;

        while ( my $conversion = $unit_conversions->next ) {
            $conversion->{transitive} or die "non-transitive not implemented";
            length $conversion->{comment} and warn "comments not displayed yet";

            my $factor = $conversion->{factor};
            my $unit1  = $units{ $conversion->{unit1_id} };
            my $unit2  = $units{ $conversion->{unit2_id} };

            push @{ $unit1->{conversions} },
              {
                factor => $factor,
                unit   => $unit2,
              };

            push @{ $unit2->{conversions} }, {
                factor => 1 / $factor,    # inverse
                unit   => $unit1,
            };

            weaken $unit1->{conversions}[-1]{unit};
            weaken $unit2->{conversions}[-1]{unit};
        }
    }

    $c->stash(
        new_url => $c->project_uri( $self->action_for('new_unit') ),
        units   => \@units,
    );
}

sub new_unit : GET HEAD Chained('/project/base') PathPart('units/new')
  RequiresCapability('edit_project') {
    my ( $self, $c ) = @_;

    $c->stash(
        template   => 'unit/edit.tt',
        create_url => $c->project_uri( $self->action_for('create') ),
    );
}

sub base : Chained('/project/base') PathPart('unit') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;

    $c->stash( unit => $c->project->units->find($id) || $c->detach('/error/not_found') );
}

sub edit : GET HEAD Chained('base') PathPart('') Args(0) RequiresCapability('edit_project') {
    my ( $self, $c ) = @_;

    my $unit = $c->stash->{unit};

    my @articles = $unit->articles->sorted->hri->all;

    for my $article (@articles) {
        $article->{url} = $c->project_uri( '/article/edit', $article->{id} );
    }

    $c->stash(
        articles   => \@articles,
        update_url => $c->project_uri( $self->action_for('update'), $unit->id ),
    );
}

sub create : POST Chained('/project/base') PathPart('units/create') Args(0)
  RequiresCapability('edit_project') {
    my ( $self, $c ) = @_;

    $c->stash( unit => $c->project->new_related( units => {} ) );
    $c->detach('update_or_insert');
}

sub update : POST Chained('base') Args(0) RequiresCapability('edit_project') {
    my ( $self, $c ) = @_;

    $c->detach('update_or_insert');
}

sub update_or_insert : Private {
    my ( $self, $c ) = @_;

    my $unit = $c->stash->{unit};

    $unit->set_columns(
        {
            short_name => $c->req->params->get('short_name'),
            long_name  => $c->req->params->get('long_name'),
        }
    );

    my @errors;

    length $unit->short_name
      or push @errors, "Short name must be set!";

    if ( length $unit->long_name ) {
        my $is_unique = not $c->project->units->results_exist(
            { ( $unit->in_storage ? ( id => { '!=' => $unit->id } ) : () ), long_name => $unit->long_name } );

        $is_unique or push @errors, "Another unit with that long name already exists!";
    }
    else {
        push @errors, "Long name must be set!";
    }

    # TODO keep input values
    if (@errors) {
        $c->messages->error($_) for @errors;

        $c->redirect_detach(
            $c->project_uri(
                $unit->in_storage
                ? ( $self->action_for('edit'), $unit->id )
                : $self->action_for('new_unit')
            )
        );
    }

    $unit->update_or_insert();

    $c->detach('redirect');
}

sub delete : POST Chained('base') Args(0) RequiresCapability('edit_project') {
    my ( $self, $c ) = @_;

    $c->stash->{unit}->delete();
    $c->detach('redirect');
}

sub redirect : Private {
    my ( $self, $c ) = @_;

    $c->response->redirect( $c->project_uri( $self->action_for('index') ) );
}

__PACKAGE__->meta->make_immutable;

1;
