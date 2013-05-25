# Type Overview
[Index](https://github.com/duckduckgo/duckduckgo#index) / **Type Overview**

---

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