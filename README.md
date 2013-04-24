DuckDuckHack Developer Overview
===
## What is this?

[DuckDuckGo](https://duckduckgo.com/) is a general purpose search engine. We've created a platform called DuckDuckHack that enables developers to write open source plugins on top of the search engine (like [add-ons for Firefox](https://addons.mozilla.org/en-US/firefox/addon/duckduckgo-ssl/?src=search)). DuckDuckGo plugins react to search queries and provide [useful](https://duckduckgo.com/?q=%40duckduckgo) [instant](https://duckduckgo.com/?q=roman+xvi) [answers](https://duckduckgo.com/?q=private+ips) above traditional links.

DuckDuckHack is very much a work in progress. Some plugin types have better interfaces than others. We will be improving the platform based on [your feedback](https://fiesta.cc/~duckduckhack).
Our long-term goal is to be able to distribute all DuckDuckHack (and internal) instant answers via the [DuckDuckGo API](https://api.duckduckgo.com). 
Currently [fathead](https://github.com/duckduckgo/zeroclickinfo-fathead) and [goodie](#goodies-overview) plugin types 
automatically flow through. We are working on exposing the other plugin types, which are more complicated to distribute
and can have licensing restrictions.

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

---

## How to follow the Documentation
This repo contains all plugin-agnostic information that you'll need. In the Getting Started section below, you'll find overviews and documentation trails for Spice and Goodie plugins. These two plugin types have more well-defined processes and you just have to follow the list of links in order to learn all you need to know. For Fathead and Longtail plugins, you should see their individual repositories for how-to instructions (linked in Getting Started). The zeroclickinfo-goodies and zeroclickinfo-spice repositories each contain more detailed information on their respective plugin types and their readme's are linked to from the tracks below. At the end of a section in one of these repos, there will always be a link that will take you back to this page and the documentation trail that you have been following.

---

## Getting Started


**Step 1.** &nbsp;Decide what you want to work on. If you don't have any ideas, [start here](http://ideas.duckduckhack.com/).

**Step 2.** &nbsp;Figure out your plugin type (see Plugin Types above). If the right type is not obvious, please <a href="FAQ.md">ask us</a>. Sometimes multiple plugin types could work, and we can help you figure out which one would work best. Consider the following when choosing what type of plugin to make.

#### Guidelines
* DuckDuckGo plugins appear at the top of search results pages, which is a **sacred space!** Please follow these guidelines to ensure the quickest path to going live.

* **Use the right [plugin type](#overview)**.  If your plugin uses external APIs in real time, it should be Spice. See the [Xkcd integration](https://duckduckgo.com/?q=xkcd) for an example.

* **Better than links**.  Since instant answers are above the traditional links, they should be unambiguously better than them. For example, the [Yummly integration](https://duckduckgo.com/?q=garlic+steak+recipe) shows recipes that are better than the links below.
![better than links](https://s3.amazonaws.com/ddg-assets/docs/better_than_links.png)

* **No false positives**.  A false positive is an irrelevant instant answer. Only return an instant answer when you know it is good, and otherwise return nothing. For example, the [Quixey plugin](http://ddg.gg/?q=flight+search+app) shouldn't show an answer for a query like "How to write an app."

* **Minimize vertical space**.  Only include the most important information and then offer the user to click through for more if needed. ![minimize space](https://s3.amazonaws.com/ddg-assets/docs/minimize_space.png)

* **Readable answers**.  If textual, create sentences or short statements that users can actually read. ![readable answer](https://s3.amazonaws.com/ddg-assets/docs/readable.png)

* **Consistent design**.  When in doubt, copy what already exists or ask us! We already have [a](http://ddg.gg/?q=garlic+steak+recipe) [few](http://ddg.gg/?q=xkcd) [cool](http://ddg.gg/?q=movies) [designs](http://ddg.gg/?q=flight+search+app).

**Step 3.** &nbsp;Fork the right repository ([GitHub instructions](http://help.github.com/fork-a-repo/)):

 * [Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies) (Perl functions)
 * [Spice](https://github.com/duckduckgo/zeroclickinfo-spice) (JavaScript functions)
 * [Fathead](https://github.com/duckduckgo/zeroclickinfo-fathead) (Keyword data)
 * [Longtail](https://github.com/duckduckgo/zeroclickinfo-longtail) (Full-text data)

**Step 4.** &nbsp;Now it's choose-your-own-adventure time!

 * For **Goodies**, check out the [Goodies Overview](#goodies-overview) below. This will give you a list of links to other pages that will guide you through the goodie process.
 * For **Spice**, proceed to the [Spice Overview](#spice-overview) below. This section will walk you through everything you need to build a basic spice plugin.

 * For **Fathead**, check out the Readme in the [fathead repository](https://github.com/duckduckgo/zeroclickinfo-fathead).
 * For **Longtail**, check out the Readme in the [longtail repository](https://github.com/duckduckgo/zeroclickinfo-longtail).

## Goodies Overview
Follow this list to go through the goodie progression.

1. **[Basic Tutorial](#basic-tutorial)** -- this will show you the fundamentals of making a plugin. It's a simple walkthrough-by-example and gives a good introduction to the system.
2. **[Testing Triggers](#testing-triggers)** -- this will lead you through how to use duckpan, our command-line utility, to test the plugins that you've written and make sure your triggers are working properly.
3. **[Submitting Plugins](#submitting-plugins)** -- this section guides you through the plugin submission process, and is the last section that you need to gain a basic understanding of the entire process.
4. Once you're familiar with the above three sections, it's time to move on the [Goodies repository](https://github.com/duckduckgo/zeroclickinfo-goodies), which contains information about advanced goodie creation, and the [Advanced](Advanced.md) plugin-agnostic docs.

## Spice Overview
Follow this list to go through the spice progression.

1. **[Basic Tutorial](#basic-tutorial)** -- this will show you the fundamentals of making a plugin. It's a simple walkthrough-by-example and gives a good introduction to the system.
2. **[Spice Handle Functions](https://github.com/duckduckgo/zeroclickinfo-spice#spice-handle-functions)** -- this section provides an overview of the different variables that a spice plugin can process.
3. **[Testing Triggers](#testing-triggers)** -- this will lead you through how to use duckpan, our command-line utility, to test the plugins that you've written and make sure your triggers are working properly.
4. **[Spice Callback Functions](https://github.com/duckduckgo/zeroclickinfo-spice#spice-callback-functions)** -- this section explains how JavaScript callback functions are generated by the plugin system.
5. **[Testing Spice](https://github.com/duckduckgo/zeroclickinfo-spice#testing-spice)** -- this section introduces you to the spice testing process.
6. **[Submitting Plugins](#submitting-plugins)** -- this section guides you through the plugin submission process, and is the last section that you need to gain a basic understanding of the entire process.
7. Once you're familiar with the above sections, it's time to move on the [Spice repository](https://github.com/duckduckgo/zeroclickinfo-spice#advanced-spice), which contains an advanced section with information about more involved spice creation, and the [Advanced](Advanced.md) plugin-agnostic docs.

## Basic Tutorial

In this tutorial, we'll be making a Goodie plugin that checks the number of characters in a given search query. The end result will look [like this](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Chars.pm) and works [like this](https://duckduckgo.com/?q=chars+How+many+characters+are+in+this+sentence%3F). The same framework is used to trigger Spice plugins.

Let's begin. Open a text editor like [gedit](http://projects.gnome.org/gedit/), notepad or [emacs](http://www.gnu.org/software/emacs/) and type the following:

```perl
package DDG::Goodie::Chars;
# ABSTRACT: Give the number of characters (length) of the query.
```

Each plugin is a [Perl package](https://duckduckgo.com/?q=perl+package), so we start by declaring the package namespace. In a new plugin, you would change **Chars** to the name of the new plugin (written in [CamelCase](https://duckduckgo.com/?q=camelcase) format).

The second line is a special comment line that gets parsed automatically to make nice documentation (by [Dist::Zilla](https://metacpan.org/module/Dist::Zilla)).

Next, type the following [use statement](https://duckduckgo.com/?q=perl+use) to import [the magic behind](https://github.com/duckduckgo/duckduckgo/tree/master/lib/DDG) our plugin system.

```perl
use DDG::Goodie;
```

---

#### A Note on Modules
Right after the above line, you should include any Perl modules that you'll be leveraging to help generate the answer. Make sure you add those modules to the dist.ini file in this repository.
If you're not using any additional modules, carry on!

----

Now here's where it gets interesting. Type:

```perl
triggers start => 'chars';
```

**triggers** are keywords that tell us when to make the plugin run. They are _trigger words_. When a particular trigger word is part of a search query, it tells DuckDuckGo to _trigger_ the appropriate plugins.

In this case there is one trigger word: **chars**. Let's say someone searched "chars this is a test." **chars** is the first word so it would trigger our Goodie. The **start** keyword says, "Make sure the trigger word is at the start of the query." The system has several other keywords like **start** that are enumerated in the [Triggers](#triggers) section. The **=>** symbol is there to separate the trigger words from the keywords (for readability).

Now type in this line:

```perl
handle remainder => sub {
```

Once triggers are specified, we define how to _handle_ the query. **handle** is another keyword, similar to triggers.

You can _handle_ different aspects of the search query, but the most common is the **remainder**, which refers to the rest of the query (everything but the triggers). For example, if the query was _"chars this is a test"_, the trigger would be _chars_ and the remainder would be _this is a test_.

Now let's add a few more lines to complete the handle function.

```perl
handle remainder => sub {
    return 'Chars: ' . length $_ if $_;
    return;
};
```

This function (the part within the **{}** after **sub**) is the meat of the Goodie. It generates the instant answer that is displayed at the top of the [search results page](https://duckduckgo.com/?q=chars+this+is+a+test).

Whatever you are handling is passed to the function in the **$_** variable ( **$_** is a special default variable in Perl that is commonly used to store temporary values). For example, if you searched DuckDuckGo for _"chars this is a test"_, the value of **$_** will be _"this is a test"_, i.e. the remainder.

Let's take a closer look at the first line of the function.

```perl
return 'Chars: ' . length $_ if $_;
```

The heart of the function is just this one line. The **remainder** is in the **$_** variable as discussed. If it is not blank ( **if $_** ), we return the number of chars using Perl's built-in [length function](https://duckduckgo.com/?q=perl+length).

Perl has a lot of built-in functions, as well as thousands and thousands of modules available [via CPAN](https://metacpan.org/). You can leverage these modules when making Goodies, similar to how the [Roman Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Roman.pm) uses the [Roman module](https://metacpan.org/module/Roman).

If we are unable to provide a good instant answer, we simply **return** nothing. And that's exactly what the second line in the function does.

```perl
return;
```

This line is only run if **$_** contained nothing, because otherwise the line before it would return something and end the function.

Now, below your function type the following line:

```perl
zci is_cached => 1;
```

This line is optional. Goodies technically return a [ZeroClickInfo object](https://metacpan.org/module/WWW::DuckDuckGo::ZeroClickInfo) (abbreviated as **zci**). This effect happens transparently by default, but you can override this default behavior via the **zci** keyword.

We set **is_cached** to true (0 is false, 1 is true) because this plugin will always return the same answer for the same query. This speeds up future answers by caching them (saving previous answers).

Finally, all Perl packages that load correctly should [return a true value](http://stackoverflow.com/questions/5293246/why-the-1-at-the-end-of-each-perl-package) so add a 1 on the very last line.

```perl
1;
```

And that's it! At this point you have a working DuckDuckHack Goodie plugin. It should look like this:

```perl
package DDG::Goodie::Chars;
# ABSTRACT: Give the number of characters (length) of the query.

use DDG::Goodie;

triggers start => 'chars';

handle remainder => sub {
    return 'Chars: ' . length $_ if $_;
    return;
};

zci is_cached => 1;

1;
```
### Review
The plugin system works like this at the highest level:

* We break the query (search terms) into words. This process happens in the background.

* We see if any of those words are **triggers** (trigger words). These are provided by each of the plugins. In the example, the trigger word is **chars**.

* If a Goodie plugin is triggered, we run its **handle** function.

* If the Goodie's handle function outputs an instant answer via a **return** statement, we pass it back to the user.

### Where to go from here

Click to return to the [Goodies Overview](#goodies-overview) or the [Spice Overview](#spice-overview).


----

Plugin-agnostic Information
===
---
## Triggers
There are two types of triggers, **words** and **regex**. The [basic tutorial](#basic-tutorial) walks through a simple example of a words trigger. While you technically *can* use a regular expression as a trigger, we encourage you to use words triggers first, and then use a regexp to further qualify the query once the plugin has been called, like in the [Xkcd example](https://github.com/duckduckgo/zeroclickinfo-spice#spice-handle-functions) in the Spice Handle Functions section. Words triggers are several orders of magnitude faster than regexp triggers (a hash check vs. a regexp match).

### Words Triggers
```
start......word exists at the start of the query
end........word exists at the end of the query
startend...word is at the beginning or end of the query
any........word is anywhere in the query
```

You can combine several trigger statements if, for example, you want certain words to be **startend** but others to be **start**. The [Average Goodie](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Average.pm#L5) is a good example of multiple words trigger statements.


### Regex Triggers

Regular expression triggers can be applied to the following query objects:

```
query_raw............the query in its most basic form, with no clean-up string operations.
query................uniformly whitespaced version of query_raw.
query_lc.............lowercase version of *query*.
query_nowhitespace...*query* with no whitespace.
query_clean..........*query_lc*, but with whitespace and non-alphanumeric ascii removed.

```
Back to [Goodies Overview](#goodies-overview) | [Spice Overview](#spice-overview) | [Basic tutorial](#basic-tutorial)

---

## Testing Triggers

Before reading this section, make sure you've at least worked through the [basic tutorial](https://github.com/duckduckgo/duckduckgo#basic-tutorial).


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
duckpan query
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

Click to return to the [Goodies Overview](#goodies-overview) or the [Spice Overview](#spice-overview).

--- 
## Submitting Plugins
**Step 1.**  &nbsp;Commit your changes.

```bash
git commit -a -m "My first plugin that does X is ready to go!"
```

**Step 2.**  &nbsp;Get your commit history [how you like it](http://book.git-scm.com/4_interactive_rebasing.html).

```
git rebase -i origin/master
```

**Step 3.**  &nbsp;Push your forked repository back to GitHub.

```
git push
```

**Step 4.** Add your info to the plugin so we can give you credit for it on the [Goodies page](https://duckduckgo.com/goodies). You'll see your name or handle on the live site!
Check out the [Metadata README](Metadata.md) for detailed instructions on how to include your name and links.


**Step 5.**  &nbsp;Go into GitHub and submit a [pull request!](http://help.github.com/send-pull-requests/) That will let us know about your plugin and start the conversation about integrating it into the live search engine.

### Where to go now:
You're pretty much done! Now it's time to learn the advanced stuff!
Click to return to the [Goodies Overview](#goodies-overview) or the [Spice Overview](#spice-overview). Each of these sections has links to follow so you can read up on the more advanced facets of plugin development.

===

FAQ
===
## Can you help me?

  Of course! Here are the easiest ways to contact someone who can help answer your questions:

 * Join us on IRC at [#duckduckgo on Freenode](http://webchat.freenode.net/?channels=duckduckgo).
 * Write the [discussion list](https://www.listbox.com/subscribe/?list_id=197814).
 * Write us privately at open@duckduckgo.com.

### What if I don't know Perl?
If you don't know Perl, that's OK! Several <a href="README.md#overview">plugin types</a> are not in Perl. Also, if you know PHP, Ruby, or Python you should be able to write Goodies in Perl pretty easily using [this awesome cheat sheet](http://hyperpolyglot.org/scripting).

### Do you have any plugin ideas?
Yup! We maintain [a growing list](http://ideas.duckduckhack.com/). There are also improvement ideas for [Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies/issues), [Spice](https://github.com/duckduckgo/zeroclickinfo-spice/issues), [Fathead](https://github.com/duckduckgo/zeroclickinfo-fathead/issues) and [Longtail](https://github.com/duckduckgo/zeroclickinfo-longtail/issues).

### How do I note that I've started on something?
In your initial pull request, please note the link on the [idea list](http://ideas.duckduckhack.com/). We'll move it to the "in process" bucket for you.

### Where I can report plugin bugs?
Submit GitHub issues in the [appropriate repo](http://github.com/duckduckgo).

### What if there are plugin conflicts?
The ultimate arbiter is the user, and that's the perspective we take. In other words, we ask "what is best for the user experience?" That said, it often makes sense to combine ideas into one, better plugin.

### Why isn't my plugin in the [DuckDuckGo API](https://api.duckduckgo.com)?
If your plugin is spice or longtail, sometimes we can't expose it through the DDG API for licensing reasons (e.g. the WolframAlpha plugin), but our
over-arching goal is to make all of our instant answers available on their own.

### Can I do something more complicated?
Maybe. There are a bunch more internal interfaces we haven't exposed yet, and we'd love to hear your ideas to influence that roadmap.

### What's the roadmap?
Here's what we're working on (in roughly in this order):

* better testing/file structure for spice plugins.
* better JS interface for spice plugin callback functions.
* better attribution.
* embedding plugins.
* better testing/file structure for fathead plugins.
* more defined structure for longtail plugins.
* better testing for longtail plugins.


**Are there other open source projects?** &nbsp;Yes! Check out the other repositories in [our GitHub account](https://github.com/duckduckgo). You can email open@duckduckgo.com if you have any questions on those.

### Can I get the instant answers through an API?
Yes! Check out the [DuckDuckGo API](https://api.duckduckgo.com). Our goal is to make as many plugins as possible
available through this interface. Fathead and goodie plugins are automatically syndicated through the API, and Spice and Longtail are selectively (due to licensing complications) mixed in.
