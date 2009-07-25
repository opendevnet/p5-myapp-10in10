package MyApp::Controller::Reminder;
use strict;
use base 'Catalyst::Controller';
use TheSchwartz::Job;
use JSON::XS;
use Email::Valid;
use Digest::MD5;

sub index :Path Args(0) {
    my ( $self, $c ) = @_;

    if ( my $email = $c->request->body_params->{email} )
    {
        if ( Email::Valid->address($email) )
        {
            my %job_data = ( email => $email );
            my $de_dupe_token = Digest::MD5::md5_hex(encode_json(\%job_data));
    
            my $job = TheSchwartz::Job->new(
                                            funcname => "MyApp::Job::Reminder",
                                            uniqkey  => $de_dupe_token,
                                            coalesce => $email,
                                            arg      => \%job_data,
                                            );

            my $job_handle = $c->model("TheSchwartz")->insert($job)
                or die "Couldn't insert a job...";

            $c->stash(job => $job_handle);
        }
        else
        {
            $c->stash(problem => "$email is not a valid address :(");
        }
    }
    # use YAML; $c->stash(dump => YAML::Dump($c->model("TheSchwartz")));
}

1;


__END__

Maybe?
my $job_handle = $c->model("TheSchwartz")->insert("MyApp::Job::Reminder", \%job_data)
    
