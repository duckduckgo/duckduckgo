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

At this point the response moves from the backend to the frontend. The external API sends a JSON object to the callback function that you will also define (as explained in the [Spice Frontend Development](https://github.com/duckduckgo/duckduckgo/blob/master/documentation/spice2.md#spice-frontend) section).

**Back to [Index](https://github.com/duckduckgo/duckduckgo) | [Spice Overview](spice_overview.md) | [Basic tutorial](general.md#basic-tutorial)**
