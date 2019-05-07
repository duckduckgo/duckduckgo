package DDG::Meta::CountryCodes;
# ABSTRACT: Master list of country renames and aliases for all IAs

use Locale::Country 'country2code';

unless(country2code('DuckDuckGo')){
    
    # Add aliases
    Locale::Country::add_country_alias('Antigua and Barbuda' => 'Antigua');
    Locale::Country::add_country_alias('Antigua and Barbuda' => 'Barbuda');
    Locale::Country::add_country_alias('Trinidad and Tobago' => 'Tobago');
    Locale::Country::add_country_alias('Trinidad and Tobago' => 'Trinidad');
    Locale::Country::add_country_alias('Vatican City' => 'Vatican');
    Locale::Country::add_country_alias('Virgin Islands, U.S.' => 'US Virgin Islands');
    Locale::Country::add_country_alias('United States' => 'America');
    
    # Rename countries
    
    # These are the only 2 countries which officially have 'The' in their name
    # Source: http://www.bbc.co.uk/news/magazine-18233844
    Locale::Country::rename_country('bs' => 'The Bahamas');
    Locale::Country::rename_country('gm' => 'The Gambia');
    Locale::Country::rename_country('ae' => 'the United Arab Emirates');
    Locale::Country::rename_country('do' => 'the Dominican Republic');
    Locale::Country::rename_country('gb' => 'the United Kingdom');
    Locale::Country::rename_country('kp' => "the Democratic People's Republic of Korea"); # North Korea
    Locale::Country::rename_country('kr' => 'the Republic of Korea'); # South Korea
    Locale::Country::rename_country('ky' => 'the Cayman Islands');
    Locale::Country::rename_country('mp' => 'the Northern Mariana Islands');
    Locale::Country::rename_country('nl' => 'the Netherlands');
    Locale::Country::rename_country('ph' => 'the Philippines');
    Locale::Country::rename_country('ru' => 'the Russian Federation');
    Locale::Country::rename_country('tw' => 'Taiwan');
    Locale::Country::rename_country('us' => 'the United States');
    Locale::Country::rename_country('va' => 'the Holy See (Vatican City State)');
    Locale::Country::rename_country('vg' => 'the British Virgin Islands');
    Locale::Country::rename_country('vi' => 'the US Virgin Islands');
    Locale::Country::rename_country('cz' => 'Czechia');
    
    # Easter eggs
    Locale::Country::add_country_alias('Russian Federation' => 'Kremlin');
    Locale::Country::add_country_alias('United States' => 'murica');
    Locale::Country::add_country_alias('Canada' => 'Canadia');
    Locale::Country::add_country_alias('Australia' => 'down under');
    Locale::Country::add_country_alias('Canada' => 'DuckDuckGo');
}

1;
