# General
[Index](https://github.com/duckduckgo/duckduckgo#index) / **General**

---
This section contains information that is largely agnostic of plugin type and is therefore relevant regardless of the type of plugin that you're working on.

## Basic Tutorial

[Index](https://github.com/duckduckgo/duckduckgo#index) / [General](#general) / **Basic Tutorial**

---

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

This line is optional. We set **is_cached** to true (0 is false, 1 is true) because this plugin will always return the same answer for the same query. This speeds up future answers by caching them (saving previous answers).

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

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Goodies Overview](goodies_overview.md) | [Spice Overview](spice_overview.md) | [Basic tutorial](#basic-tutorial)**

***

## Triggers
[Index](https://github.com/duckduckgo/duckduckgo#index) / [General](#general) / **Triggers**

---
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
**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Goodies Overview](goodies_overview.md) | [Spice Overview](spice_overview.md) | [Basic tutorial](#basic-tutorial)**

***

## Submitting Plugins
[Index](https://github.com/duckduckgo/duckduckgo#index) / [General](#general) / **Submitting Plugins**

---

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
Check out the [Metadata README](metadata.md) for detailed instructions on how to include your name and links.


**Step 5.**  &nbsp;Go into GitHub and submit a [pull request!](http://help.github.com/send-pull-requests/) That will let us know about your plugin and start the conversation about integrating it into the live search engine.


**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Goodies Overview](goodies_overview.md) | [Spice Overview](spice_overview.md) | [Basic tutorial](#basic-tutorial)**
