DuckDuckHack Developer Overview
===
## What is this?

[DuckDuckGo](https://duckduckgo.com/) is a general purpose search engine. We've created a platform called DuckDuckHack that enables developers to write open source plugins on top of the search engine (like [add-ons for Firefox](https://addons.mozilla.org/en-US/firefox/addon/duckduckgo-ssl/?src=search)). DuckDuckGo plugins react to search queries and provide [useful](https://duckduckgo.com/?q=%40duckduckgo) [instant](https://duckduckgo.com/?q=roman+xvi) [answers](https://duckduckgo.com/?q=private+ips) above traditional links.

DuckDuckHack is very much a work in progress. Some plugin types have better interfaces than others. We will be improving the platform based on [your feedback](https://fiesta.cc/~duckduckhack).

This site will always have the latest platform information.

* For new plugins, follow [@duckduckhack](https://twitter.com/duckduckhack)
* For ongoing discussion: [DuckDuckHack list](https://www.listbox.com/subscribe/?list_id=197814)


## Why should I make plugins?

We hope you will consider making DuckDuckGo plugins to:

* Improve results in areas you personally search and care about, e.g. [programming documentation](https://duckduckgo.com/?q=perl+split), [gaming](https://duckduckgo.com/?q=roll+3d12+%2B+4) or [entertainment](https://duckduckgo.com/?q=xkcd).
* Increase usage of your own projects, e.g. data and [APIs](https://duckduckgo.com/?q=cost+of+living+nyc+philadelphia).
* Learn something new.
* Attribution [on our site](https://duckduckgo.com/goodies.html) and [Twitter](https://twitter.com/duckduckhack) (working on more).
* See your code live on a [growing](https://duckduckgo.com/traffic.html) search engine!

##Overview

There are currently four types of DuckDuckGo plugins:

### Goodies &mdash; calculations and cheat sheets.

 * Examples: [reverse](https://duckduckgo.com/?q=reverse+test), [private ips](https://duckduckgo.com/?q=private+ip), [dice](https://duckduckgo.com/?q=throw+5+dice), [roman](https://duckduckgo.com/?q=roman+cvi), [passphrase](https://duckduckgo.com/?q=passphrase+4+words), [etc.](https://github.com/duckduckgo/zeroclickinfo-goodies/tree/master/lib/DDG/Goodie)
 * Status: v1!
 * Language: Perl
 * Involves: processing the search query.

### Spice &mdash; external API calls.

 * Examples: [xkcd](https://duckduckgo.com/?q=xkcd), [alternative to](https://duckduckgo.com/?q=alternative+to+picasa), [twitter](https://duckduckgo.com/?q=%40duckduckgo), [wordnik](https://duckduckgo.com/?q=random+word+3-5), [expatistan](https://duckduckgo.com/?q=cost+of+living+nyc+philadelphia), [etc.](https://github.com/duckduckgo/zeroclickinfo-spice/tree/master/lib/DDG/Spice)
 * Status: v1 release candidate
 * Language: JavaScript
 * Involves: processing data from APIs.

### Fathead &mdash; keyword databases.

 * Examples: [git](https://duckduckgo.com/?q=git+branch), [perl](https://duckduckgo.com/?q=perl+split), [final fantasy](http://duckduckgo.com/?q=gippal), [emoticons](http://duckduckgo.com/?q=%28%3E_%3C%29), [http](http://duckduckgo.com/?q=http+304), [etc.](https://github.com/duckduckgo/zeroclickinfo-fathead)
 * Status: alpha
 * Languages: Perl, Node, Ruby, Python (maybe others)
 * Involves: generating information about specific queries.

### Longtail &mdash; full-text data.

 * Examples: [wikipedia](https://duckduckgo.com/?q=snow+albedo), [lyrics](https://duckduckgo.com/?q=what%27s+my+age+again+lyrics), [stack overflow](https://duckduckgo.com/?q=nginx+apache), [etc.](https://github.com/duckduckgo/zeroclickinfo-longtail)
 * Status: alpha
 * Languages: Perl, Node, Ruby, Python (maybe others)
 * Involves: formatting data sets to answer general queries.


## Getting Started


**Step 1.** &nbsp;Decide what you want to work on. If you don't have any ideas, [start here](http://ideas.duckduckhack.com/).

**Step 2.** &nbsp;Figure out your plugin type (see Plugin Types above). If the right type is not obvious, please <a href="FAQ.md">ask us</a>. Sometimes multiple plugin types could work, and we can help you figure out which one would work best.

**Step 3.** &nbsp;Fork the right repository ([GitHub instructions](http://help.github.com/fork-a-repo/)):

 * [Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies) (Perl functions)
 * [Spice](https://github.com/duckduckgo/zeroclickinfo-spice) (JavaScript functions)
 * [Fathead](https://github.com/duckduckgo/zeroclickinfo-fathead) (Keyword data)
 * [Longtail](https://github.com/duckduckgo/zeroclickinfo-longtail) (Full-text data)

**Step 4.** &nbsp;Now it's choose-your-own-adventure time!

 * For **Goodies** or **Spice**, proceed to the [Basic tutorial](https://github.com/duckduckgo/zeroclickinfo-goodies) in the Goodies repository.

 * For **Fathead**, check out the Readme in the [fathead repository](https://github.com/duckduckgo/zeroclickinfo-fathead).
 * For **Longtail**, check out the Readme in the [longtail repository](https://github.com/duckduckgo/zeroclickinfo-longtail).

Advanced Stuff
===

## Testing Triggers
### Pre-requisites:
Before reading this section, make sure you've at least worked through the [basic tutorial](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/README.md#basic-tutorial).


----

**Step 1.** &nbsp;Install our DuckDuckHack utility called [duckpan](https://metacpan.org/module/App::DuckPAN):

```bash
curl http://duckpan.org/install.pl | perl
```

[This script](https://github.com/duckduckgo/p5-duckpan-installer) will setup [local::lib](https://metacpan.org/module/local::lib), which is a way to install Perl modules without changing your base Perl installation. (If you already use local::lib or [perlbrew](https://metacpan.org/module/perlbrew), don't worry, this script will intelligently use what you already have.)

If you didn't have a local::lib before running the install script, you will need to run the script twice. It should tell you when like this:

```txt
please now re-login to your user account and run it again!
```

If everything works, you should see this at the end:

```bash
EVERYTHING OK! You can now go hacking! :)
```

Note that with local::lib now installed, you can easily install [Perl modules](http://search.cpan.org/) with [cpanm](https://metacpan.org/module/cpanm).

```bash
cpanm App::DuckPAN
App::DuckPAN is up to date.
```

**Step 2.** &nbsp;Go to your fork of the repository (a directory or folder on your computer).

```bash
cd zeroclickinfo-goodies/
```

**Step 3.** &nbsp;Install the repository requirements using duckpan.

```txt
duckpan installdeps
```

This command will install all the Perl modules used by the DuckDuckGo plugins within your local repository. These requirements are defined in the [/dist.ini file](http://blog.urth.org/2010/06/walking-through-a-real-distini.html) (at the root).

**Step 4.** Add your plugin.

Make a new file in the **lib/DDG/Goodie/** directory for Goodies or the **lib/DDG/Spice/** directory for Spice. The name of the file is the name of the plugin followed by the extension **.pm** because it is a Perl package. For example, if the name of your plugin was _TestPlugin_, the file would be _TestPlugin.pm_.

**Step 5.** Test your trigger(s) interactively.

Type this command at the command line.

```txt
duckpan goodie test
```

First, this command will output all of the plugins available in your local plugin repository.

```md
Using the following DDG::Goodie plugins:

 - DDG::Goodie::Xor (Words)
 - DDG::Goodie::SigFigs (Words)
 - DDG::Goodie::EmToPx (Words)
 - DDG::Goodie::Length (Words)
 - DDG::Goodie::ABC (Words)
 - DDG::Goodie::Chars (Words)
 ...
```

You should see your plugin in there as well. When the output is finished it gives you an interactive prompt.

```
(Empty query for ending test)
Query:
```

Now you can type in any query and see what the response will be.

```
Query: chars this is a test

DDG::ZeroClickInfo  {
    Parents       WWW::DuckDuckGo::ZeroClickInfo
    Linear @ISA   DDG::ZeroClickInfo, WWW::DuckDuckGo::ZeroClickInfo, Moo::Object
    public methods (3) : is_cached, new, ttl
    private methods (0)
    internals: {
        answer   14,
        answer_type   "chars",
        is_cached   1
    }
}
```

There is a lot of debugging output, but you will want to pay special attention to the internals section.

```txt
    internals: {
        answer   14,
        answer_type   "chars",
        is_cached   1
    }
```

Here you can see the answer returned, as well as any **zci** keywords (by default there will be a default **answer_type** and **is_cached** value).

Simply hit enter (a blank query) to exit interactive mode.

```txt
Query:

\_o< Thanks for testing!
```

### Where to go now:

* You may want to build a test file in the [Advanced trigger testing](#advanced-trigger-testing) section.
* If you're making a **Goodie** plugin, you can go directly to the [Submitting plugins](#submitting-plugins) section.
* If you're following along with the **Spice** plugin docs, you should go to the section on [Spice callback functions](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/README.md#spice-callback-functions).
