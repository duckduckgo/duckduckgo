DuckDuckHack Developer Overview
===
## What is this?

[DuckDuckGo](https://duckduckgo.com/) is a general purpose search engine. We've created a platform called [DuckDuckHack](http://duckduckhack.com/) that enables developers to write open source plugins on top of the search engine (like [add-ons for Firefox](https://addons.mozilla.org/en-US/firefox/addon/duckduckgo-for-firefox/?src=ss)). DuckDuckGo plugins react to search queries and provide [useful](https://duckduckgo.com/?q=%40duckduckgo) [instant](https://duckduckgo.com/?q=roman+xvi) [answers](https://duckduckgo.com/?q=private+ips) above traditional links.

If you want to get involved in making DuckDuckGo a better search engine, you've come to the right place! 

* If you are a developer, this guide serves as a master jumping-off point for the DuckDuckHack platform.
* If you are not a developer, but would like to become one to help with DuckDuckHack, we recommend the [JavaScript course at Codecademy](http://www.codecademy.com/tracks/javascript). That will help you to get started with the Spice plugin type (explained below).
* If you have no intention of becoming a developer, there is still a lot you can do at our [ideas companion site](http://ideas.duckduckhack.com/) where you can suggest and comment on plugin ideas such as identifying the best sites and data sources to draw from. Similarly, you can submit [issues about current plugins](https://github.com/duckduckgo/duckduckgo/issues?direction=desc&sort=created&state=open). Both of these activities are very valuable and will help direct community efforts.

DuckDuckHack is very much a work in progress. Some plugin types have better interfaces than others. We will be improving the platform based on [your feedback](https://www.listbox.com/subscribe/?list_id=197814).
Our long-term goal is to be able to distribute all DuckDuckHack (and internal) instant answers via the [DuckDuckGo API](https://api.duckduckgo.com). 
Currently [fathead](https://github.com/duckduckgo/zeroclickinfo-fathead) and [goodie](#goodies-overview) plugin types 
automatically flow through. We are working on exposing the other plugin types, which are more complicated to distribute
and can have licensing restrictions.

* For new plugins, follow [@duckduckhack](https://twitter.com/duckduckhack)
* For ongoing discussion: [DuckDuckHack list](https://www.listbox.com/subscribe/?list_id=197814)

## Index

* [For non-coders](documentation/faq.md#what-if-im-not-a-coder-at-all)
* [Why should I make plugins?](documentation/faq.md#why-should-i-make-plugins)
* [Getting Started](documentation/getting_started.md)
	* [Determining Plugin Type](documentation/getting_started.md#determining-plugin-type)
	* [Guidelines](documentation/getting_started.md#guidelines)
* [General](documentation/general.md)
	* [Basic Tutorial](documentation/general.md#basic-tutorial)
	* [Triggers](documentation/general.md#triggers)
	* [Submitting Plugins](documentation/general.md#submitting-plugins)
* [Goodies Overview](documentation/goodies_overview.md)
 	* [Basic Tutorial](documentation/general.md#basic-tutorial)
 	* [Testing Triggers](documentation/testing.md#testing-triggers)
 	* [Submitting Plugins](documentation/general.md#submitting-plugins)
 	* [Advanced Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies)
* [Spice Overview](documentation/spice_overview.md)
	* [Basic Tutorial](documentation/general.md#basic-tutorial)
	* [Spice Handle Functions](documentation/spice.md#spice-handle-functions)
	* [Testing Triggers](documentation/testing.md#testing-triggers)
	* [Spice Callback Functions](documentation/spice.md#spice-callback-functions)
	* [Testing Spice](documentation/testing.md#testing-spice)
	* [Submitting plugins](documentation/general.md#submitting-plugins)
	* [Advanced Spice](https://github.com/duckduckgo/zeroclickinfo-spice)
* [Fathead Overview](https://github.com/duckduckgo/zeroclickinfo-fathead)
* [Longtail Overview](https://github.com/duckduckgo/zeroclickinfo-longtail)
* [FAQ](documentation/faq.md)


