# Functions for finding and editing aliases and redirects for a website

# list_redirects(&domain)
# Returns a list of URL paths and destinations for redirects and aliases. Each
# is a hash ref with keys :
#   path - A URL path like /foo
#   dest - Either a URL or a directory
#   alias - Set to 1 for an alias, 0 for a redirect
#   regexp - If set to 1, any sub-path is redirected to the same destination
sub list_redirects
{
my ($d) = @_;
&require_apache();
local ($virt, $vconf) = &get_apache_virtual($d->{'dom'}, $d->{'web_port'});
return ( ) if (!$virt);
my @rv;
foreach my $al (&apache::find_directive_struct("Alias", $vconf),
		&apache::find_directive_struct("AliasMatch", $vconf),
		&apache::find_directive_struct("Redirect", $vconf),
                &apache::find_directive_struct("RedirectMatch", $vconf),
	       ) {
	my $rd = { 'dest' => $al->{'words'}->[1],
		   'alias' => $al->{'name'} =~ /^Alias/i ? 1 : 0,
		   'dir' => $al };
	if ($al->{'name'} eq 'Alias') {
		$rd->{'path'} = $al->{'words'}->[0];
		push(@rv, $rd);
		}
	elsif ($al->{'name'} eq 'AliasMatch' &&
	       $al->{'words'}->[0] =~ /^(.*)\.\*\$$/) {
		$rd->{'path'} = $1;
		$rd->{'regexp'} = 1;
		push(@rv, $rd);
		}
	}
return @rv;
}

# create_redirect(&domain, &redirect)
# Creates a new alias or redirect in some domain
sub create_redirect
{
my ($d, $redirect) = @_;
&require_apache();
my @ports = ( $d->{'web_port'},
	      $d->{'ssl'} ? ( $d->{'web_sslport'} ) : ( ) );
my $count = 0;
foreach my $port (@ports) {
	my ($virt, $vconf, $conf) = &get_apache_virtual($d->{'dom'}, $port);
	next if (!$virt);
	my $dir = $redirect->{'alias'} ? "Alias" : "Redirect";
	$dir .= "Match" if ($redirect->{'regexp'});
	my @aliases = &apache::find_directive($dir, $vconf);
	push(@aliases, $redirect->{'path'}.
			($redirect->{'regexp'} ? "\.\*\$" : "").
			" ".
			$redirect->{'dest'});
	&apache::save_directive($dir, \@aliases, $vconf, $conf);
	&flush_file_lines($virt->{'file'});
	$count++;
	}
if ($count) {
	&register_post_action(\&restart_apache);
	return undef;
	}
return "No Apache virtualhost found";
}

sub delete_redirect
{
}

sub modify_redirect
{
}

1;
