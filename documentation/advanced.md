Advanced
===
----
## Advanced Triggers
In the [Basic tutorial](general.md#basic-tutorial) we walked through a one word trigger and in the [Spice handle functions](spice.md#spice-handle-functions) section we walked through a simple regexp trigger.

Here are some more advanced trigger techniques you may need to use:

**Multiple trigger words**. &nbsp;Suppose you thought that in addition to _chars_, _numchars_ should also trigger the [Chars Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Chars.pm). You can simply add extra trigger words to the triggers definition.

```perl
triggers start => 'chars', 'numchars';
```

**Trigger locations.** &nbsp;The keyword after triggers, **start** in the Chars example, specifies where the triggers need to appear. Here are the choices:

 * start - just at the start of the query
 * end - just at the end of the query
 * startend - at either end of the query
 * any - anywhere in the query

**Combining locations.** &nbsp;You can use multiple locations like in the [Drinks Spice](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Drinks.pm).

```perl
triggers any => "drink", "make", "mix", "recipe", "ingredients";
triggers start => "mixing", "making";
```

**Regular Expressions.** &nbsp;As we walked through in the [Spice handle functions](spice.md#spice-handle-functions) section you can also trigger on a regular expression.

```perl
triggers query_lc => qr/^@([^\s]+)$/;
```

We much prefer you use trigger words when possible because they are faster on the backend. In some cases regular expressions are necessary, e.g. when you need to trigger on sub-words. However, you should still consider using a word trigger and a **regex guard**. A regex guard is a return clause immediately inside the handle function. A good example of this is the Base64 goodie. Here's an excerpt from Base64.pm:

```perl
triggers startend => "base64";

handle remainder => sub {
    return unless $_ =~ /^(encode|decode|)\s*(.*)$/i;
```

This way, we get the speed of the word trigger and still ensure that the search query is an exact match for our plugin. You can also return similarly (without a value) at any point in the handle function if the answer cannot be calculated.


**Regexp types.** &nbsp;Like trigger words, regular expression triggers have several keywords as well. In the above example **query_lc** was used, which operates on the lower case version of the full query. Here are the choices:

 * **query_raw** - the actual (full) query
 * **query** - with extra whitespace removed
 * **query_lc** - lower case version of the query and extra whitespace removed
 * **query_clean** - lower case with non alphanumeric ASCII and extra whitespace removed
 * **query_nowhitespace** - with whitespace totally removed
 * **query_nowhitespace_nodash** - with whitespace and dashes totally removed

If you want to see some test cases where these types are enumerated check out our [internal test file](https://github.com/duckduckgo/duckduckgo/blob/master/t/15-request.t) that tests they are generated properly.

**Two-word+ triggers** &nbsp;Right now trigger words only operate on single words. If you want to operate on a two or more word trigger, you have a couple of options.

 * Use a regular expression trigger like in the [Expatistan Spice](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Expatistan.pm).

```perl
triggers query_lc => qr/cost of living/;
```

 * Use single word queries and then further qualify the query within the handle function as explained in the [Advanced handle functions](#advanced-handle-functions) section.

## Advanced Handle Functions

In the [Basic tutorial](general.md#basic-tutorial) we walked through a simple query transformation and in the [Spice handle functions](spice.md#spice-handle-functions) section we walked through a simple return of the query.

Here are some more advanced handle techniques you may need to use:

**Further qualifying the query.** &nbsp;Trigger words are blunt instruments; they may send you queries you cannot handle. As such, you generally need to further qualify the query (and return nothing in cases where the query doesn't really qualify for your goodie).

There are number of techniques for doing so. For example, the first line of [Base Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Base.pm) has a return statement paired with unless.

```perl
return unless  /^([0-9]+)\s*(?:(?:in|as)\s+)?(hex|hexadecimal|octal|oct|binary|base\s*([0-9]+))$/;
```

You could also do it the other way, like the [GoldenRatio Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/GoldenRatio.pm).

```perl
if ($input =~ /^(?:(?:(\?)\s*:\s*(\d+(?:\.\d+)?))|(?:(\d+(?:\.\d+)?)\s*:\s*(\?)))$/) {
```

Another technique is to use a hash to allow specific query strings, as the [GUID Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/GUID.pm) does.

```
my %guid = (
    'guid' => 0,
    'uuid' => 1,
    'globally unique identifier' => 0,
    'universally unique identifier' => 1,
    'rfc 4122' => 0,
    );

return unless exists $guid{$_};
```

**Handling the whole query.** &nbsp;In the Chars example, we handled the **remainder**. You can also handle:

* **query_raw** - the actual (full) query
* **query** - with extra whitespace removed
* **query_parts** - like query but given as an array of words
* **query_nowhitespace** - with whitespace totally removed
* **query_nowhitespace_nodash** - with whitespace and dashes totally removed

For example, the [Xor Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Xor.pm) handles query_raw and the [ABC Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/ABC.pm) handles query_parts.

**Using files**. &nbsp;You can use simple text/html input files for display or processing.

```perl
# IO should always be done outside of the handle function
my @words = share('words.txt')->slurp;
```

The [Passphrase Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Passphrase.pm) does this for processing purposes and the [PrivateNetwork Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/PrivateNetwork.pm) does it for display purposes.

The files themselves go in the **/share/goodie/** directory.

**Generating data files.** You may also need to generate data files. If you do so, please also include the generation scripts. These do not have to be done in Perl, and you can also put them within the **/share/goodie/** directory. For example, the [CurrencyIn Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/tree/master/share/goodie/currency_in) uses a Python script to generate the input data.


There are a couple more sections on advanced handle techniques depending on [Plugin type](#overview):

* For **Goodies**, check out the [Advanced Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies#advanced-goodies) section.
* For **Spice**, check out the [Advanced Spice handlers](https://github.com/duckduckgo/zeroclickinfo-spice#advanced-spice-handlers) section.

## Advanced Testing
The [testing triggers](testing.md#testing-triggers) section explained interactive testing. Before going live we also make programmatic tests for each plugin.

**Step 1.** &nbsp;Add your plugin test file.

Make a new file in the test directory **t/**. The name of the file is the name of your plugin, but this time followed by the extension **.t** for test because it is a Perl testing file. For example, if the name of your plugin was _TestPlugin_, the file would be _TestPlugin.t_.

The top of the file reads like a normal Perl script with some use statements to include testing modules, including the DuckDuckGo testing module.

```perl
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;
```

Then you define any default **zci** values that you set in your plugin.

```perl
zci answer_type => 'chars';
zci is_cached => 1;
```

These should match exactly what you set in your **.pm** file.

Next comes the actual testing function.

```
ddg_goodie_test(
        [qw(
                DDG::Goodie::Chars
        )],
        'chars test' => test_zci('Chars: 4'),
        'chars this is a test' => test_zci('Chars: 14'),
);
```

For each test, you include a line like this:

```perl
        'chars test' => test_zci('Chars: 4'),
```

The first part, **'chars test'** in this example, is the test query. The second part, **test_zci('Chars: 4')** calls the test function and checks if **Chars: 4** is the answer.

Finally you end a testing file with this line.

```perl
done_testing;
```

The full file should look like this:

```perl
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;

zci answer_type => 'chars';
zci is_cached => 1;

ddg_goodie_test(
        [qw(
                DDG::Goodie::Chars
        )],
        'chars test' => test_zci('Chars: 4'),
        'chars this is a test' => test_zci('Chars: 14'),
);

done_testing;
```

If you have a long list of queries that need to be tested, you can map over an array or hash inside `ddg_goodie_test`. Remember, this is a Perl program, so we have all the normal tools at our disposal to construct a list to pass to the function.


```perl
#!/usr/bin/env perl

use strict;
use warnings;
use Test::More;
use DDG::Test::Goodie;

zci answer_type => 'time_conversion';
zci is_cached => 1;

ddg_goodie_test(
	[qw(
		DDG::Goodie::UnixTime
	)],
	map {
		"$_ 0" => test_zci('Unix Time Conversion: Thu Jan 01 00:00:00 1970 +0000'),
	}, [ 'unixtime', 'time', 'timestamp', 'datetime', 'epoch', 'unix time', 'unix epoch' ]
);

done_testing;
```



**Step 2.** &nbsp;Test your plugin programmatically.

Run your plugin test file like this:

```txt
perl -Ilib t/Chars.t
```

If successful, you should see a lot of **ok** lines.

```txt
ubuntu@yegg:~/zeroclickinfo-goodies$ perl -Ilib t/Chars.t
ok 1 - Testing query chars test
ok 2 - Testing query chars this is a test
1..2
```

If unsuccessful, you will see one or more **not ok** lines followed with some debugging output to help you chase down the error(s).

```txt
ok 1 - Testing query chars test
not ok 2 - Testing query chars this is a test
#   Failed test 'Testing query chars this is a test'
#   at /usr/local/ddg.cpan/perl5/lib/perl5/DDG/Test/Goodie.pm line 69.
#     Structures begin differing at:
#          $got->{answer} = '14'
#     $expected->{answer} = '15'
1..2
# Looks like you failed 1 test of 2.
```

