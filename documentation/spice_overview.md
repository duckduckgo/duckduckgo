# Spice Tutorial
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Spice Tutorial**

---
Spice plugins are triggered by a backend Perl component that then calls the JSON API of an upstream service. The API response is wrapped in a JavaScript function call. You, the plugin author, define this callback function and handle the API's response on the client side, generating the display from the data returned by the API.

**Important:** This is a pretty long document, but it's broken up into logical sections. Follow along and by the end, you'll have all the knowledge you need for Spice creation.

## Table of Contents

1. **[Basic Tutorial](#basic-tutorial)** -- this will show you the fundamentals of making a plugin. It's a simple walkthrough-by-example and gives a good introduction to the system. The plugin that we construct is technically a Goodie, but Goodies are the building-blocks of Spice plugins.
2. **[Spice Handle Functions](#spice-handle-functions)** -- this section provides an overview of the different variables that a spice plugin can process.
3. **[Testing Triggers](#testing-triggers)** -- this will lead you through how to use duckpan, our command-line utility, to test the plugins that you've written and make sure your triggers are working properly.

Steps 1-3 complete the back-end portion of the Spice development process. These steps contain all of the relevant information pertaining to the Perl piece of the plugin and teach you how to make the system trigger your plugin. Once you've mastered this process, it's time to move on to the front-end documentation, which shows you how to construct the JavaScript part of your plugin that will run in the browser and set your plugin's style.

**[Spice Frontend](spice2.md)** -- once you have the Perl part of the spice working, you still need to define the JS parts and the style.

After reading the frontend section, you will have completed the development process. All that remains is to [test](#testing-spice) and read the [guidelines for submission](#submitting-plugins). You can also find more advanced plugin information in the following places:

**[Advanced Spice](https://github.com/duckduckgo/zeroclickinfo-spice#advanced-spice)** contains a section with information about more involved Spice creation, specifically regarding Spice backends.

**[Advanced Frontend Techniques](spice2.md#advanced-techniques)** has some good information on more complex frontend design.

**[Advanced General](advanced.md)** contains advanced plugin-agnostic docs.

---

## Basic Tutorial

Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [General](general.md#general) / **Basic Tutorial**

---

In this tutorial, we'll be making a Goodie plugin that checks the number of characters in a given search query. The purpose of the tutorial is to show how triggers work, which is also relevant for spice development. The end result will look [like this](https://github.com/duckduckgo/zeroclickinfo-goodies/blob/master/lib/DDG/Goodie/Chars.pm) and works [like this](https://duckduckgo.com/?q=chars+How+many+characters+are+in+this+sentence%3F). The same framework is used to trigger Spice plugins.


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

In this case there is one trigger word: **chars**. Let's say someone searched "chars this is a test." **chars** is the first word so it would trigger our Goodie. The **start** keyword says, "Make sure the trigger word is at the start of the query." The system has several other keywords like **start** that are enumerated in the [Triggers](general.md#triggers) section. The **=>** symbol is there to separate the trigger words from the keywords (for readability).

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

**Now**: continue down to Spice Handle Functions, or go back to the [Table of Contents](#table-of-contents).

***

## Spice Handle Functions
Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [Spice](spice.md#spice) / **Spice Handle Functions**

---
Spice plugins have **triggers** and **handle** functions like Goodies, as explained above in the [Basic tutorial](#basic-tutorial). The difference is that Spice handle functions don't return an instant answer directly like Goodies. Instead, they return arguments used to call an external API, which then calls a JavaScript callback function that finally returns the instant answer.

The JavaScript callback function is defined in another file and is explained in detail in the [Frontend documentation](spice2.md) section. For now let's concentrate on how it gets called via the Spice handle function.

Usually the Spice plugin flow works like this:

* Spice plugin is triggered.
* Spice handle function is called.
* Spice handle function returns arguments.
* Arguments are used to make a call to an external [JSONP](https://duckduckgo.com/?q=jsonp) API.
* The external API returns a [JSON](https://duckduckgo.com/?q=JSON) object to the Spice callback function.
* Spice callback function returns instant answer.
* Instant answer formatted on screen.

The following is [an example](https://duckduckgo.com/?q=npm+uglify-js) that calls [the Node.js package search API](http://registry.npmjs.org/uglify-js/latest). Within your **zeroclickinfo-spice** fork, you would define a similar file in the **/lib/DDG/Spice/** directory. This file is named **Npm.pm**.

```perl 

package DDG::Spice::Npm;

use DDG::Spice;

spice to => 'http://registry.npmjs.org/$1/latest';
spice wrap_jsonp_callback => 1;

spice is_cached => 0;

triggers startend => 'npm';

handle remainder => sub {
	return $_ if $_;
	return;
};

1;

```

To refresh your memory, the **triggers** keyword tells the plugin system when to call a plugin. In the [Basic Tutorial](#basic-tutorial) we discussed using the **start** keyword to specify trigger words that need to be present at the beginning of the query. Check out the section on [Triggers](general.md#triggers) for more information.


Previously we saw the use of the **remainder** keyword as in **handle remainder**, which works well for trigger words. We use it again here.

```perl
    return $_ if $_;
```

`$_` is a contextual variable in Perl. Its value in this case is the **remainder**. That is, `uglify-js` in the linked example above -- the query with the trigger word stripped out. If we get a non-blank package name, we return it.

Otherwise, we return nothing, which short-circuits the eventual external call.

```perl
   return;
```

When the package name is returned we then plug it into the **spice to** definition.

```perl
spice to => 'http://registry.npmjs.org/$1/latest';
```

The **$_** value from the return statement will get inserted into the **$1** placeholder in the **spice to** line such that you can plug in parameters to the API call as needed. For passing multiple parameters, check out the [Advanced spice handlers](https://github.com/duckduckgo/zeroclickinfo-spice#advanced-spice-handlers) section.

In this particular case, the API we're using to search for packages does not support callback functions. That is, it will not wrap its response in a function call, which in this case would be **ddg_spice_npm**. If it did support a callback, we could use the **{{callback}}** template in the **spice to** line to automatically fill in the default callback value. See the [IMdB spice](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/lib/DDG/Spice/Imdb.pm) for a simple implementation of the **{{callback}}** template. Since this API doesn't support the callback parameter, we tell the backend to automatically wrap the API's response in a function call for us with:

```perl
spice wrap_jsonp_callback => 1;
```

At this point the response moves from the backend to the frontend. The external API sends a JSON object to the callback function that you will also define, as explained in the following sections. However, before starting work on the front end, we first have to test the plugin triggers to ensure that they work.

**Now:** go on Testing Triggers, or go back to the [Table of Contents](#table-of-contents).

***

## Testing Triggers
Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [Testing](testing.md#testing) / **Testing Triggers**

---


**Step 1.** &nbsp;Install our DuckDuckHack utility called [duckpan](https://metacpan.org/module/App::DuckPAN):

**Warning:** Installing duckpan can take a long time (up to 1 hour on some systems), and Linux is the only offical supported OS. It's possible to get duckpan to work on Mac OS X with a bit of perseverance, but Linux systems are preferrable. Get in touch (see [FAQ](faq.md)) for help with installing duckpan on a Mac.

```bash
curl http://duckpan.org/install.pl | perl
```

[This script](https://github.com/duckduckgo/p5-duckpan-installer) will setup [local::lib](https://metacpan.org/module/local::lib), which is a way to install Perl modules without changing your base Perl installation. (If you already use local::lib or [perlbrew](https://metacpan.org/module/perlbrew), don't worry, this script will intelligently use what you already have).

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

This command will install all the Perl modules used by the DuckDuckGo plugins within your local repository. These requirements are defined in the [/dist.ini file](http://blog.urth.org/2010/06/walking-through-a-real-distini.html) (at the root). **Warning:** this also may take a while.

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

**Now:** go on to [Spice Frontend](#spice-frontend), or go back to the [Table of Contents](#table-of-contents).

***

## Spice Frontend
Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [Spice](spice.md#spice) / **Spice Frontend**

---
**Note**: The Perl part of the plugins go in lib directory: `lib/DDG/Spice/PluginName.pm`, while all of the frontend files discussed below should go in the share directory: `share/spice/plugin_name/`.


The NPM plugin [[link](https://duckduckgo.com/?q=npm+uglify-js)] [[code](https://github.com/duckduckgo/zeroclickinfo-spice/tree/master/share/spice/npm)] is a great example of a basic Spice implementation. Let's walk through it line-by-line:

#####npm.js
```javascript
function ddg_spice_npm (api_result) {
    if (api_result.error) return

    Spice.render({
         data              : api_result,
         force_big_header  : true,
         header1           : api_result.name + ' (' + api_result.version + ')',
         source_name       : "npmjs.org", // More at ...
         source_url        : 'http://npmjs.org/package/' + api_result.name,
         template_normal   : 'npm',
         template_small    : 'npm'
    });
}
```

As mentioned, every plugin requires a Spice callback function, for the *NPM* plugin, the callback is the `ddg_spice_npm()` function that we defined here in *npm.js*. The *NPM* Perl module we wrote specifies this as the callback by using the name of the package `DDG::Spice::NPM` and gives this *ddg_spice_npm* name to the API call (well, in this particular case, tells the Perl backend to wrap the API response in the correct function call since the API doesn't support callbacks) so that this funtion will be executed when the API responds using the data returned from the upstream (API) provider as the function's input.

#####npm.js (continued)
```javascript 
if (api_result.error) return
```
Pretty self-explanatory - If the error object in the API result is defined, then break out of the function and don't show any results. In the case of this API, when the error object is defined, it means no results are given, so we have no data to use for a Spice result. Note that ```api_result.error``` is not a generalized object property and is specific to this API. Other APIs may have different names for their error responses.

#####npm.js (continued)
```javascript
Spice.render({
     data              : api_result,
     force_big_header  : true,
     header1           : api_result.name + ' (' + api_result.version + ')',
     source_name       : "npmjs.org",
     source_url        : 'http://npmjs.org/package/' + api_result.name,
     template_normal   : 'npm',
     template_small    : 'npm'
});
```

Alright, so here is the bulk of the plugin, but it's very simple:

- `Spice.render()` is a function that the plugin system has already defined. You pass an object to it that specifies a bunch of important parameters. 

- `data` is perhaps the most important parameter. The object given here will be the object that is passed along to the Handlebars template. In this case, the context of the NPM template will be the **api_result** object. This is very important to understand because **only the data passed along to the template is accessible to the template**. In most cases the `data` parameter should be set to 
`api_result` so all the data returned from the API is accessible to the template. 

- `force_big_header` is related to the display formatting -- it forces the system to display the large grey header that you see when you click the example link above. 

- `header1` is the text of this header, i.e. the text displayed inside the large grey bar. 

- `source_name` is the name of the source for the "More at <source>" link that's displayed below the text of the plugin for attribution purposes. 

- `source_url` is the target of the "More at" link. It's the page that the user will click through to. 

- `template_normal` is the name of the Handlebars template that contains the structure information for your plugin.

- `template_small` is the name of the Handlebars template to be used when you plugin is displayed in a stacked state. This isn't required, but if your plugin can provide a succint, one or two line answer this template should be used in the event that the plugin appears in the stacked state. If no template is given the stacked result will simply show the header of the spice result 

----

Now, let's look at the NPM plugin's Handlebars template:

######npm.handlebars
```html
<div>
    <div>{{{description}}}</div>
    <pre> $ npm install {{{name}}}</pre>
</div>
```

As you can see, this is a special type of HTML template. Within the template, you can refer directly to objects that are returned by the API. `description` and `name` are both from the `api_result` object that we discussed earlier -- the data that's returned by the API. All of `api_result`'s sub-objects (e.g. `name`, `description`) are in the template's scope. You can access them by name using double or triple curly braces (triple braces will not escape the contents). Here, we just create a basic HTML skeleton and fill it in with the proper information.

###Conclusion
We've created two files in the Spice share directory (`share/spice/npm/`) :

1. `npm.js` - which delegates the API's response and calls `Spice.render()`
2. `npm.handlebars` - which specifies the plugin's HTML structure and determines which attributes of the API response are placed in the HTML result

You may notice other plugins also include a css file. For **NPM** the use of CSS wasn't necessary and this is also true for many other plugins. If however CSS is needed it can be added. Please refer to the [Frontend FAQ](spice2.md#faq) for more inforamtion about custom css.

You can find plenty more examples of Spice frontend code in the dedicated document on frontend development, found [here](spice2.md).

**Now:** go on Testing Spice, or go back to the [Table of Contents](#table-of-contents).

## Testing Spice
Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [Testing](testing.md#testing) / **Testing Spice**

---

You should have already tested your Spice triggers by following the [Testing triggers](#testing-triggers) section. Once you're confident your triggers are functioning properly, follow these steps to see your Spice plugin on a live server!

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

Once everything is working properly (and you have stuff displayed on screen), you will want to mess with your callback function to get the display nice and perfect. Check out the [Guidelines](getting_started.md#guidelines) for some pointers.

**Step 7.** &nbsp;Document. 

Finally, please document as much as possible using in-line comments.

**Now:** You're almost done! Read up on how to submit plugins, or go back to the [Table of Contents](#table-of-content).

## Submitting Plugins
Also in: [Index](https://github.com/duckduckgo/duckduckgo#index) / [General](general.md#general) / **Submitting Plugins**

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


**Now:** If you're interested, go back to the [Table of Contents](#table-of-contents) and check out the Advanced links for more information. Otherwise, get hacking!
