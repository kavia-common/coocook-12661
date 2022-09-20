use Test2::V0;

use lib 't/lib/';
use TestDB;

plan(5);

my $db = TestDB->new;

my $user              = $db->resultset('User')->find(1);
my $organization_user = $user->organizations_users->one_row();
my $organization      = $organization_user->organization;

my $project = $db->resultset('Project')->create(
    {
        name        => 'foo',
        description => '',
        owner_id    => 2,
    }
);

like warning { ok !$user->has_any_project_role($project) } => qr/zero roles/;

ok !$user->has_any_project_role( $project, qw< foo bar > );

$organization->organizations_projects->create(
    {
        project_id => $project->id,
        role       => 'foo'
    }
);

ok $user->has_any_project_role( $project, qw< foo bar > );
ok $user->has_any_project_role( $project, [qw< foo bar >] );
