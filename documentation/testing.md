# Testing
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Testing**

---
This section of the documentation walks you through the process of testing everything that you've written so far, and is crucial to ensuring a smooth integration process. Don't forget to write your test files!

## Interactive Testing
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Testing](#testing) / **Testing Triggers**

---

Before reading this section, make sure you've at least worked through the [basic tutorial](general.md#basic-tutorial).


**Step 1.** &nbsp;Install our DuckDuckHack utility called [DuckPAN](https://github.com/duckduckgo/p5-app-duckpan). You can find instructions [here](https://github.com/duckduckgo/p5-app-duckpan/blob/master/README.md). It is also hosted [here](https://metacpan.org/module/App::DuckPAN) on MetaCPAN.

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

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Goodies Overview](goodies_overview.md) | [Spice Overview](spice_overview.md) | [Basic tutorial](general.md#basic-tutorial)**

***

## Plugin Test Files
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Testing](#testing) / **Goodie Test Files**

---

Every plugin includes a test file in the `t` directory. These test files include sample queries and are run automatically before every release to ensure that all goodies are triggering properly. They are also very helpful while developing plugins as a tool to quickly test code iterations. Once you've written a test file, you can test it on it's own with `perl -Ilib t/TestName.t`, or together with all other tests in the repository using `prove -Ilib`.

Goodies and Spice use a similar test structure, but test different things. Here we'll see an examples of testing files, first for Goodies, then Spice:

### Goodies

For this example, we will look at the test file of the **RouterPasswords** Goodie, which is `t/RouterPasswords.t`.

```perl
#!/usr/bin/env perl

use strict;
use warnings;

# These modules are necessary for the functions we'll be running.
use Test::More;
use DDG::Test::Goodie;

# These zci attributes aren't necessary, but if you specify them inside your
# goodie, you'll need to add matching values here to check against.
zci answer_type => 'password';
zci is_cached => 1;

ddg_goodie_test(
	[
        # This is the name of the goodie that will be loaded to test.
		'DDG::Goodie::RouterPasswords'
    ],
    # This is a sample query, just like the user will enter into the DuckDuckGo
    # search box.
	'Belkin f5d6130' =>
        test_zci(
            # The first argument to test_zci is the plain text (default)
            # returned from a goodie.  If your goodie also returns an HTML
            # version, you can pass that along explicitly as the second
            # argument. If your goodie is random, you can use regexs instead of
            # strings to match against.
            'Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'
        ),
    # You should include more test cases here. Try to think of ways that your
    # plugin might break, and add them here to ensure they won't. Here are a
    # few others that were thought of for this goodie.
	'Belkin f5d6130 password default' =>
        test_zci('Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'),
	'default password Belkin f5d6130' =>
        test_zci('Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'),
	'Belkin f5d6130 password' =>
        test_zci('Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'),
	'default BELKIN password f5d6130' =>
        test_zci('Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'),
	'password bELKIN default f5d6130' =>
        test_zci('Default login for the BELKIN F5D6130: Username: (none) Password: password',
            html => 'Default login for the BELKIN F5D6130:<br><i>Username</i>: (none)<br><i>Password</i>: password'),
);

# This function call is expected by Test::More. It makes sure the program
# doesn't exit before all the tests have been run.
done_testing;
```

### Spice

For this example, we will look at the test file of the **Xkcd** Spice, which is `t/Xkcd.t`.

```perl
#!/usr/bin/env perl

use strict;
use warnings;

# These modules are necessary for the functions we'll be running.
use Test::More;
use DDG::Test::Spice;

ddg_spice_test(
	[
        # This is the name of the Spice will be loaded to test.
		'DDG::Spice::Xkcd'
    ],
    # This is a sample query, just like the user will enter into the DuckDuckGo
    # search box.
    '619 xkcd' => test_spice(
        # The first argument is the Spice callback. It includes the javascript
        # endpoint and the argument list contructed by the Perl code. In this
        # case, the endpoint is '/js/spice/xkcd/', and the argument returned by
        # the Perl code is 619.
        '/js/spice/xkcd/619',
        # This is the Spice calltype. It's almost always set to 'include',
        # except for some special cases like FlashVersion which don't make a
        # normal API call.
        call_type => 'include',
        # This is the Spice that should be triggered by the query.
        caller => 'DDG::Spice::Xkcd',
        # This is the cache value to expect. It's only necessary if you specify
        # one in your Spice.
        is_cached => 0
    ),
    # You should include more test cases here. Try to think of ways that your
    # plugin might break, and add them here to ensure they won't. Here are is
    # another that is tested for this Spice.
    'xkcd' => test_spice(
        '/js/spice/xkcd/',
        call_type => 'include',
        caller => 'DDG::Spice::Xkcd',
        is_cached => 0
    ),
);

# This function call is expected by Test::More. It makes sure the program
# doesn't exit before all the tests have been run.
done_testing;
```

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Goodies Overview](goodies_overview.md)**

***

## Testing Spice HTML
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Testing](#testing) / **Testing Spice HTML**

---

You should have already tested your Spice triggers by following the [Testing triggers](https://github.com/duckduckgo/duckduckgo#testing-triggers) section. Once you're confident your triggers are functioning properly, follow these steps to see your Spice plugin on a live server!

**Step 1.**  &nbsp;Go to the roof of your forked repository.

```bash
cd zeroclickinfo-spice/
```

**Step 2.**  &nbsp;Start the server.

```bash
duckpan server
```

This command will start up a small Web server running on port 5000 on your machine.

**Step 3.**  &nbsp;Visit the server in your browser.

You should now be able to go to your duckpan server via a regular Web browser and check it out. It runs code from our site and so generally looks like a real version of DuckDuckGo. 

If you're running the duckpan server on the same computer as your Web browser you can navigate to:

```bash
http://127.0.0.1:5000/
```

If you're running the duckpan server on a remote machine, then substitute 127.0.0.1 wither either its IP address or its Fully Qualified Domain Name.

**Step 4.**  &nbsp;Search.

Given you've already tested your plugin triggers, you should be able to search and see your spice output come through the server. As requests go through the internal Web server they are printed to STDOUT (on the screen). External API calls are highlighted (if you have color turned on in your terminal).

**Step 5.** &nbsp;Debug.

If for some reason a search doesn't hit a plugin, there is an error message displayed on the homepage saying "Sorry, no hit for your plugins." 

If it does hit and you do not see something displayed on the screen, a number of things could be going wrong.

* You have a JavaScript error of some kind. Check out the JavaScript console for details. Personally we like to use [Firebug](http://getfirebug.com/) internally.

* The external API was not called correctly. You should be able to examine the Web server output to make sure the right API is being called. If it's not you will need to revise your [Spice handle function](#spice-handle-functions).

* The external API did not return anything. Firebug is great for checking this as well. You should see the call in your browser and then you can examine the response.


**Step 6.** &nbsp;Tweak the display.

Once everything is working properly (and you have stuff displayed on screen), you will want to mess with your callback function to get the display nice and perfect. Check out the [Guidelines](https://github.com/duckduckgo/duckduckgo#guidelines) for some pointers.

**Step 7.** &nbsp;Document. 

Finally, please document as much as possible using in-line comments.

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Spice Overview](spice_overview.md) | [Basic tutorial](general.md#basic-tutorial)**
