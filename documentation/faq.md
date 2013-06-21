#FAQ
[Index](https://github.com/duckduckgo/duckduckgo/) / **FAQ**

---

### Why should I make plugins?

We hope you will consider making DuckDuckGo plugins to:

* Improve results in areas you personally search and care about, e.g. [programming documentation](https://duckduckgo.com/?q=perl+split), [gaming](https://duckduckgo.com/?q=roll+3d12+%2B+4) or [entertainment](https://duckduckgo.com/?q=xkcd).
* Increase usage of your own projects, e.g. data and [APIs](https://duckduckgo.com/?q=cost+of+living+nyc+philadelphia).
* Learn something new.
* Attribution [on our site](https://duckduckgo.com/goodies.html) and [Twitter](https://twitter.com/duckduckhack) (working on more).
* See your code live on a [growing](https://duckduckgo.com/traffic.html) search engine!

### What if I'm not a coder at all?

If you don't code at all and you've ended up here, please go over to our [ideas companion site](http://ideas.duckduckhack.com/) where you can suggest and comment on plugin ideas such as identifying the best sites and data sources to draw from. Similarly, you can submit [issues about current plugins](https://github.com/duckduckgo/duckduckgo/issues?direction=desc&sort=created&state=open). Both of these activities are very valuable and will help direct community efforts.

If you're a business and want your data to be utilized, adding your service to [ideas.duckduckhack.com](http://ideas.duckduckhack.com) is a great way for your API to get picked up by a developer and integrated into the search engine.


### Can you help me?

  Of course! Here are the easiest ways to contact someone who can help answer your questions:

 * Write us publicly on the [discussion list](https://www.listbox.com/subscribe/?list_id=197814).
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

### Why isn't my plugin in the [DuckDuckGo Instant Answers API](https://api.duckduckgo.com)?
If your plugin is spice or longtail, sometimes we can't expose it through the API for licensing reasons (e.g. the WolframAlpha plugin), but our
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

### Are there other open source projects? 
Yes! Check out the other repositories in [our GitHub account](https://github.com/duckduckgo). You can email open@duckduckgo.com if you have any questions on those.

### Can I get the instant answers through an API?
Yes! Check out the [DuckDuckGo API](https://api.duckduckgo.com). Our goal is to make as many plugins as possible
available through this interface. Fathead and goodie plugins are automatically syndicated through the API, and Spice and Longtail are selectively (due to licensing complications) mixed in.

### Can I talk to you about a partnership idea?###
Sure -- check out [our partnerships page](http://help.duckduckgo.com/customer/portal/articles/775109-partnerships).
