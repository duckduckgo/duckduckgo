# Plugin Metadata

Metadata allows us to categorize and describe plugins. This information is put in the main perl module for each plugin that you write.
See [Information.pm][1] for more details. Existing plugins can be found on the [current goodies page][3] for reference.

Broken down below are the different types of metadata that you can add to your plugin.

## Example Queries

Each plugin needs example queries. Primary examples are listed in the middle
column, and secondary examples are alternatives linked from the third column.


    primary_example_queries   "square root of nine";
    secondary_example_queries "cube root of 8", "fifth root of one hundred twenty nine";

## Description

The description, as the name suggests, is a succinct description of what the plugin does. Try to *exclude* the
source if possible, so write "graph equations" instead of "graph equations at
wolfram alpha"

    description "graph equations";

## Name

An arbitrary unique name for the goodie -- you should stick to what you've decided to call you *PluginName*.pm file to avoid confusion.

    name "RedditSearch";

## icon_url

URL to an icon that is representative of your plugin -- the favicon for the
data source or DuckDuckHack are recommended. You can leave this parameter blank for a DDG/DDH icon. The favicon is
not always at http://url/favicon.ico, but is often given an explicit URL in the
HTML header as x-icon or apple-touch-icon or something similar.

    icon_url "/i/math.stackexchange.com.ico";             # using DDG icon cache

    icon_url "http://www.canistream.it/img/Icon-72.png";  # link to specific favicon location

## Source

Name of the data source (which you shouldn't have in your description).

    source "Wolfram|Alpha";

## code_url

URL to the plugin code on github.

    code_url "https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/TitleCase.pm";

## Topics

Broad classes that your plugin provides insight into. Feel free to assign multiple topics as necessary, as it often makes sense to put
goodies in several topics.

	topics "science", "geography", "trivia";

Supported topics are listed in [Information.pm][6]


## Category

Specific activities or descriptive nouns for plugins, i.e., what the plugin does (conversion, calculation, etc). For now, limit yourself to one category. Just put it in the most obvious category and don't overthink it -- we'll let you know if there's a better one.

	category "calculations";

Supported categories are listed at [Information.pm][5]


## Attribution

    attribution github => ['https://github.com/adman','Adman'],
                twitter => ['http://twitter.com/adman_X','adman_X'];

Supported attribution methods are listed at [Information.pm][4]


[1]:https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Meta/Information.pm
[2]:https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Meta/ZeroClickInfo.pm
[3]:http://duckduckgo.com/goodies/
[4]:https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Meta/Information.pm#L10
[5]:https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Meta/Information.pm#L19
[6]:https://github.com/duckduckgo/duckduckgo/blob/master/lib/DDG/Meta/Information.pm#L48

### Where to go now
---
Back to [Submitting Plugins](https://github.com/duckduckgo/duckduckgo#submitting-plugins) | [Goodies Overview](https://github.com/duckduckgo/duckduckgo#goodies-overview) | [Spice Overview](https://github.com/duckduckgo/duckduckgo#spice-overview)
