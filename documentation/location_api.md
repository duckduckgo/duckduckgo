# Location API
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Location API**

---

Sometimes, a plugin needs the user's location. This is where the Location API comes in. An example is the [Is it snowing?](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Snow.pm) plugin. Before reading this, you should be familiar with the genereal workings of your plugin type.

The Location API is implemented by [DuckDuckGo](https://github.com/duckduckgo/duckduckgo), which is a package used by Plugins. When testing Plugins interactively with `duckpan`, the location will always point to "Phoenixville, Pennsylvania, United States," but don't worry - it will show the real location once it's live.

Inside the handlers of Goodies and Spice, the `$loc` variable refers to a Location object that can be accessed. Here's the code that the [Is it snowing?](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Snow.pm) Spice is using to read the location.

```perl
# Phoenixville, Pennsylvania, United States
my $location = join(", ", $loc->city, $loc->region_name, $loc->country_name);
```

It isn't limited to just the city, the state, and the country. [Location.pm](https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Location.pm#L6) lists all the things that you can possibly use:

```perl
my @geo_ip_record_attrs = qw( country_code country_code3 country_name region
    region_name city postal_code latitude longitude time_zone area_code
    continent_code metro_code );
```

Sample contents of `$loc`:

```perl
longitude => -75.5385
country_name => United States
area_code => 610
region_name => Pennsylvania
country_code => US
region => PA
continent_code => NA
city => Phoenixville
postal_code => 19460
latitude => 40.1246
time_zone => America/New_York
metro_code => 504
country_code3 => USA
```

## Testing the Location API

To write a test for a location aware Plugin, you'll need to pass the test function an extra parameter - a `DDG::Request` object, with the location specified. To do this, you'll need to `use DDG::Test::Location` and `use DDG::Request`. Here is a working annotated example excerpted from the **Goodie::HelpLine** test file `t/HelpLine.t`. The same process should be used for Spice.

Note that only a small set of locations are available to be simulated for testing. They are defined in [DDG::Test::Location.pm](https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Test/Location.pm#L18).


```perl
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Spice;

# These two modules are only necessary when testing with the Location API.
use DDG::Test::Location;
use DDG::Request;

ddg_spice_test(
    [qw( DDG::Spice::Snow )],
    # This optional argument to ddg_goodie_test is a DDG::Request object.
    # The object constructor takes two arguments of its own:
    # the query (usually specified in the test_zci),
    # and a location object - created by test_location (with a country code).
    DDG::Request->new(
        query_raw => "is it snowing?",
        location => test_location("de")
    ) => test_spice(
        '/js/spice/snow/'
        .'M%C3%B6nchengladbach%2C%20%20Nordrhein-Westfalen%2C%20%20Germany',
        call_type => 'include',
        caller => 'DDG::Spice::Snow',
    ),
    # The DDG::Request is used in place of a query string, and isn't necessary
    # to be used with every test passed to ddg_spice_test.
    'is it snowing in new york?' => test_spice(
        '/js/spice/snow/new%20york',
        call_type => 'include',
        caller => 'DDG::Spice::Snow',
    )
);

done_testing;
```

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Basic tutorial](general.md#basic-tutorial)**
