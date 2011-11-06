package DDG::Site::DuckDuckGo;

use Moose;
extends 'DDG::Site';

sub key { 'duckduckgo' }

sub default_stash {{}}

sub locales { 'en_US', 'de_DE', }

sub _build_statics {
	my ( $self ) = @_;
	my $return = {
		$self->get_locale_statics('settings','settings',{
			extra_head => 'head/settings.tt',
			setting_blocks => [
				{
					id => 'result',
					name => 'Result Settings',
					settings => [
						{
							id => 'safe',
							cookie => 'p',
							save_id => 'save0',
							name => 'Safe Search',
							desc => 'Omits objectionable material.',
							options => [
								1 => 'On',
								-1 => 'Off',
							],
						},{
							id => 'lr',
							cookie => 'l',
							save_id => 'save1',
							name => 'Region',
							desc => 'Boosts results from the region.',
							no_translate => 1,
							add_empty => 1,
							no_default => 1,
							options => [
								'xa-ar' => 'Arabia',
								'xa-en' => 'Arabia (en)',
								'ar-es' => 'Argentina',
								'au-en' => 'Australia',
								'at-de' => 'Austria',
								'be-fr' => 'Belgium (fr)',
								'be-nl' => 'Belgium (nl)',
								'br-pt' => 'Brazil',
								'bg-bg' => 'Bulgaria',
								'ca-en' => 'Canada',
								'ca-fr' => 'Canada (fr)',
								'ct-ca' => 'Catalan',
								'cl-es' => 'Chile',
								'cn-zh' => 'China',
								'co-es' => 'Colombia',
								'hr-hr' => 'Croatia',
								'cz-cs' => 'Czech Republic',
								'dk-da' => 'Denmark',
								'ee-et' => 'Estonia',
								'fi-fi' => 'Finland',
								'fr-fr' => 'France',
								'de-de' => 'Germany',
								'gr-el' => 'Greece',
								'hk-tzh' => 'Hong Kong',
								'hu-hu' => 'Hungary',
								'in-en' => 'India',
								'id-id' => 'Indonesia',
								'id-en' => 'Indonesia (en)',
								'ie-en' => 'Ireland',
								'il-he' => 'Israel',
								'it-it' => 'Italy',
								'jp-jp' => 'Japan',
								'kr-kr' => 'Korea',
								'lv-lv' => 'Latvia',
								'lt-lt' => 'Lithuania',
								'xl-es' => 'Latin America',
								'my-ms' => 'Malaysia',
								'my-en' => 'Malaysia (en)',
								'mx-es' => 'Mexico',
								'nl-nl' => 'Netherlands',
								'nz-en' => 'New Zealand',
								'no-no' => 'Norway',
								'pe-es' => 'Peru',
								'ph-en' => 'Philippines',
								'ph-tl' => 'Philippines (tl)',
								'pl-pl' => 'Poland',
								'pt-pt' => 'Portugal',
								'ro-ro' => 'Romania',
								'ru-ru' => 'Russia',
								'sg-en' => 'Singapore',
								'sk-sk' => 'Slovak Republic',
								'za-en' => 'South Africa',
								'es-es' => 'Spain',
								'se-sv' => 'Sweden',
								'ch-de' => 'Switzerland (de)',
								'ch-fr' => 'Switzerland (fr)',
								'ch-it' => 'Switzerland (it)',
								'tw-tzh' => 'Taiwan',
								'th-th' => 'Thailand',
								'tr-tr' => 'Turkey',
								'ua-uk' => 'Ukraine',
								'uk-en' => 'United Kingdom',
								'us-en' => 'United States',
								'ue-es' => 'United States (es)',
								've-es' => 'Venezuela',
								'vn-vi' => 'Vietnam',
								'wt-wt' => 'World Traveler (none)',
							],
						},{
							id => 'disambiguation',
							cookie => 'i',
							save_id => 'save17',
							name => 'Meanings',
							desc => 'For ambiguous terms, asks you to choose which meaning is right.',
							options => [
								1 => 'On',
								-1 => 'Off',
							],
						},{
							id => 'zeroclick',
							cookie => 'z',
							save_id => 'save14',
							name => '0-click box',
							desc => 'Red box above results with useful info.',
							options => [
								1 => 'On',
								-1 => 'Off',
							],
						},{
							id => 'scroll',
							cookie => 'c',
							save_id => 'save10',
							name => 'Auto-load',
							desc => 'Auto-load more results when using mouse scroll wheel.',
							options => [
								1 => 'On',
								-1 => 'Off',
							],
						},{
							id => 'newwindow',
							cookie => 'n',
							save_id => 'save_n',
							name => 'New window',
							desc => 'Open results in new windows/tabs.',
							options => [
								-1 => 'Off',
								1 => 'On',
							],
						},{
							id => 'fav',
							cookie => 'f',
							save_id => 'save9',
							name => 'Site icons',
							desc => 'Small icons to the left of results.',
							options => [
								b => 'Favicons + WOT warnings (default)',
								1 => 'Just favicons',
								w => 'Just WOT (trust) ratings',
								fw => 'All WOT + favicons (both)',
								-1 => 'Off',
							],
						},{
							id => 'embed',
							cookie => 'b',
							save_id => 'save18',
							name => 'Embeds',
							desc => 'Small icons to the left of results.',
							options => [
								b => 'Favicons + WOT warnings (default)',
								1 => 'Just favicons',
								w => 'Just WOT (trust) ratings',
								fw => 'All WOT + favicons (both)',
								-1 => 'Off',
							],
						},
					],
				},
			],
		}),
		$self->get_locale_statics('index','index',{
			extra_head => 'head/index.tt',
		}),
	};
	return $return;
}

1;