# Spice
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Spice**

---

This documentation section contains spice-specific plugin information. Its contents are relevant if you're doing anything related to spice.

## Spice Handle Functions
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Spice](#spice) / **Spice Handle Functions**

---
Spice plugins have **triggers** and **handle** functions like Goodies, as explained in the [Basic tutorial](http://github.com/duckduckgo/duckduckgo#basic-tutorial). The difference is that Spice handle functions don't return an instant answer directly like Goodies. Instead, they return arguments used to call a JavaScript callback function that then returns the instant answer.

The JavaScript callback function is defined in another file and is explained in detail in the [Spice callback functions](#spice-callback-functions) section. For now let's concentrate on how it gets called via the Spice handle function.

Usually the Spice plugin flow works like this:

* Spice plugin is triggered.
* Spice handle function is called.
* Spice handle function returns arguments.
* Arguments are used to make a call to an external [JSONP](https://duckduckgo.com/?q=jsonp) API.
* The external API returns a [JSON](https://duckduckgo.com/?q=JSON) object to the Spice callback function.
* Spice callback function returns instant answer.
* Instant answer formatted on screen.

The following is [an example](https://duckduckgo.com/?q=twitter+duckduckgo) that calls [the Twitter API](http://twitter.com/status/user_timeline/duckduckgo.json?callback=ddg_spice_twitter). Within your **zeroclickinfo-spice** fork, you would define a similar file in the **/lib/DDG/Spice/** directory. This file is named **Twitter.pm**.

```perl
package DDG::Spice::Twitter;

use DDG::Spice;

spice to => 'http://twitter.com/status/user_timeline/$1.json?callback={{callback}}';

triggers query_lc => qr/^@([^\s]+)$/;

handle matches => sub {
    my ($uname) = @_;
    return $uname if $uname;
    return;
};

1;
```

To refresh your memory, the **triggers** keyword tells the plugin system when to call a plugin. In the [Basic Tutorial](general.md#basic-tutorial) we discussed using the **start** keyword to specify trigger words that need to be present at the beginning of the query. Check out the section on [Triggers](general.md#triggers) for more information.

In situations where you want to trigger on sub-words, you can pass a regular expression like in this Twitter example. 

```perl
triggers query_lc => qr/^@([^\s]+)$/;
```

The **query_lc** keyword tells the trigger system to examine a lower case version of the query. The **qr/regexp/** construct is the way to specify a compiled regular expression in Perl. 

In this case **^@([^\s]+)$** says look for a **@** character at the beginning of the query (the **^**) and capture (using the parenthesis) everything that isn't a space ( **[^\s]** ) until you get to the end of the query (the **$**). Therefore it will match a query like *@duckduckgo* and capture the *duckduckgo* part.

The captured parts (matches) get passed to the **handle** function via the **@_** variable (a special Perl array variable).

```perl
handle matches => sub {
    my ($uname) = @_;
    return $uname if $uname;
    return;
};
```

Previously we saw the use of the **remainder** keyword as in **handle remainder**, which works well for trigger words. In a case like this one that uses a regular expression trigger, the equivalent is **handle matches**, which passes the captured parts of the regular expression to the handle function. We look at what was passed and put it into the **$uname** variable.

```perl
    my ($uname) = @_;
```

If we received a non-blank user name then we return it.

```perl
    return $uname if $uname;
```

Otherwise, return nothing, which short circuits the eventual external call.

```perl
   return;
```

When the username is returned we then plug it into the **spice to** definition.

```perl
spice to => 'http://twitter.com/status/user_timeline/$1.json?callback={{callback}}';
```

The **$uname** value from the return statement will get inserted into the **$1** placeholder in the **spice to** line such that you can plug in parameters to the API call as needed. For passing multiple parameters, check out the [Advanced spice handlers](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/README.md#advanced-spice-handlers) section.

The **{{callback}}** template gets plugged in automatically with the default callback value of **ddg_spice_twitter**. That last part (twitter) is a lowercase version of the plugin name with different words separated by the **_** character.

At this point the response moves from the backend to the frontend. The external API sends a JSON object to the callback function that you will also define (as explained in the [Spice callback functions](#spice-callback-functions) section).

**Back to [Index](https://github.com/duckduckgo/duckduckgo) | [Spice Overview](spice_overview.md) | [Basic tutorial](general.md#basic-tutorial)**

***
## Spice Callback Functions
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Spice](#spice) / **Spice Callback Functions**

---
Before reading this section, make sure you've read the [basic tutorial](general.md#basic-tutorial), the section on [spice handle functions](#spice-handle-functions), and the section on [testing triggers](testing.md#testing-triggers).

As explained in the [Spice handle functions](#spice-handle-functions) section, a Spice plugin usually calls an external API and returns a JSON object to a callback function. This section explains what that callback function looks like.

*Please note:* the interface of the callback function is the most beta part of the Spice system, and will be changing soon (for the better). However, you can work away without worrying about what any changes might do to your plugins -- we'll take care of all that.

The callback function is named **ddg_spice_plugin_name** where **plugin_name** becomes the name of your plugin. For example, for the [Twitter plugin](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/share/spice/twitter/spice.js) the callback name is **ddg_spice_twitter**. For multiple word names the CamelCase in the plugin name becomes lower case and separated by _, e.g. HackerNews becomes hacker_news.

Whereas the Spice handle function went in the **/lib/DDG/Spice/** directory, the callback function goes in the **/share/spice/plugin_name** directory. You will need to make that directory. The callback function then gets placed inside a file called **spice.js**.

Here's a very simple callback function used in the [Expatistan Spice](https://github.com/duckduckgo/zeroclickinfo-spice/blob/master/share/spice/expatistan/spice.js) at **/share/spice/expatistan/spice.js**:

```js
function ddg_spice_expatistan(ir) {
    var snippet = '';
    if (ir['status'] == 'OK') {
       snippet = ir['abstract'];
       items = new Array();
       items[0] = new Array();
       items[0]['a'] = snippet;
       items[0]['h'] = '';
       items[0]['s'] = 'Expatistan';
       items[0]['u'] = ir['source_url'];
       nra(items);
    }
}
```

The end result is a call to the **nra** function, an internal display function that takes what you send it and formats it for instant answer display. 

```js
       nra(items);
```

We're sending it a JavaScript Array we created called items.

```js
       items = new Array();
```

The first item in the Array is the main answer. It is another JavaScript Array.

```js
       items[0] = new Array();
```

An item takes the following parameters. 

```js
items[0]['a'] = snippet;
```

The **a** param is the required answer. It can be pure HTML in which case it is set via innerHTML. It can also be an object (preferred), in which case onclick and other event handlers won't be destroyed.

The **h** param is an optional relevant (and relatively short) title. 

```js
items[0]['h'] = title;
```

Source name and URL are required in the **s** and **u** blocks. These are used to make the More at X link in all instant answer boxes. Think of it as source attribution.

```js
items[0]['s'] = 'XKCD';
items[0]['u'] = url
```

An optional image can be passed in the **i** param. If there is a thumbnail image, we will display it on the right.

```
items[0]['i'] = image_url
```

You would usually get the information to make these assignments via the object returned to the callback function. In this case we received it in the **ir** variable but you can name it anything.

```js
function ddg_spice_expatistan(ir) {
```

**Back to [Index](https://github.com/duckduckgo/duckduckgo#index) | [Spice Overview](spice_overview.md) | [Basic tutorial](general.md#basic-tutorial)**

