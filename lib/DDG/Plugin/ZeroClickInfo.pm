package DDG::Plugin::ZeroClickInfo;

use Moo::Role;

with qw(
	DDG::Plugin
);

use DDG::ZeroClickInfo;

sub type { 'E' }

has answer_type => (
	is => 'ro',
	lazy => 1,
	builder => '_build_answer_type',
);

sub _build_answer_type {
	my ( $self ) = @_;
	my $class = ref $self;
	my @parts = split(/::/,$class);
	shift @parts; shift @parts; shift @parts;
	return lc(join(' ',@parts));
}

sub query {
	my ( $self, $query, $parameter ) = @_;
	my @result = $self->simple_query($query->query,@{$parameter});
	return unless @result;
	if (ref $result[0] eq 'HASH') {
		return $self->get_zci($result[0]);
	} elsif (ref $result[0] eq '') {
		return $self->get_zci({
			answer => join("\n",@result),
			answer_type => $self->answer_type,
			type => $self->type,
		});
	}
}

sub get_zci {
	my ( $self, $hash ) = @_;
	return DDG::ZeroClickInfo->new($hash);
}

sub simple_query {}

1;