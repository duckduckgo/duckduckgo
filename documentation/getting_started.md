# Getting Started
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Getting Started**

---

**Step 1.** &nbsp;Decide what you want to work on. If you don't have any ideas, [start here](http://ideas.duckduckhack.com/).

**Step 2.** &nbsp;Figure out your plugin type. If the right type is not obvious, please <a href="https://github.com/duckduckgo/duckduckgo#can-you-help-me">ask us</a>. Sometimes multiple plugin types could work, and we can help you figure out which one would work best. Consider the [guidelines](#guidelines) when choosing what type of plugin to make and check out the [flow chart](#determining-plugin-type).

**Step 3.** &nbsp;Fork the right repository ([GitHub instructions](http://help.github.com/fork-a-repo/)):

 * [Goodies](https://github.com/duckduckgo/zeroclickinfo-goodies) (Perl functions)
 * [Spice](https://github.com/duckduckgo/zeroclickinfo-spice) (JavaScript functions)
 * [Fathead](https://github.com/duckduckgo/zeroclickinfo-fathead) (Keyword data)
 * [Longtail](https://github.com/duckduckgo/zeroclickinfo-longtail) (Full-text data)

**Step 4.** &nbsp;Now it's choose-your-own-adventure time!

***Important:*** The documentation contained herein is additive. In order to make a Spice plugin, for example, you must first understand how to make a Goodie plugin. This is because the back-end of a Spice plugin is essentially just a goodie that injects an HTTP call into the client JS instead of returning an answer. 

 * For **Goodies**, check out the [Goodies Overview](goodies_overview.md). This will give you a list of links to other pages that will guide you through the goodie process.
 * For **Spice**, proceed to the [Spice Overview](spice_overview.md). This section will walk you through everything you need to build a basic spice plugin.

 * For **Fathead**, check out the Readme in the [fathead repository](https://github.com/duckduckgo/zeroclickinfo-fathead).
 * For **Longtail**, check out the Readme in the [longtail repository](https://github.com/duckduckgo/zeroclickinfo-longtail).
 
## Determining Plugin Type
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Getting Started](#getting-started) / **Determining Plugin Type**

---

Check out this flow chart to determine what type of plugin you should create. Also refer to the [Type Overview](overview.md) for detailed explanations and examples of each type.

![plugin type flow chart](https://s3.amazonaws.com/ddg-assets/docs/plugin_flow.png)

## Guidelines
[Index](https://github.com/duckduckgo/duckduckgo#index) / [Getting Started](#getting-started) / **Guidelines**

---

* DuckDuckGo plugins appear at the top of search results pages, which is a **sacred space!** Please follow these guidelines to ensure the quickest path to going live.

* **Use the right [plugin type](#determining-plugin-type)**. Check out the linked flow chart.

* **Better than links**. Since instant answers are above the traditional links, they should be unambiguously better than them. For example, the [Yummly integration](https://duckduckgo.com/?q=garlic+steak+recipe) shows recipes that are better than the links below.
![better than links](https://s3.amazonaws.com/ddg-assets/docs/better_than_links.png)

* **No false positives**. A false positive is an irrelevant instant answer. Only return an instant answer when you know it is good, and otherwise return nothing. For example, the [Quixey plugin](http://ddg.gg/?q=flight+search+app) shouldn't show an answer for a query like "How to write an app."

* **Minimize vertical space**.  Only include the most important information and then offer the user to click through for more if needed. 
![minimize space](https://s3.amazonaws.com/ddg-assets/docs/minimize_space.png)

* **Readable answers**.  If textual, create sentences or short statements that users can actually read. ![readable answer](https://s3.amazonaws.com/ddg-assets/docs/readable.png)

* **Consistent design**.  When in doubt, copy what already exists or ask us! We already have [a](http://ddg.gg/?q=garlic+steak+recipe) [few](http://ddg.gg/?q=xkcd) [cool](http://ddg.gg/?q=movies) [designs](http://ddg.gg/?q=flight+search+app).


 
