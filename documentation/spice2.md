#Spice Frontend

--------

#Index
- [Overview](#overview)
    - [Tech](#tech)
- [Example #1: NPM (Basic Plugin)](#example-1---npm-basic-plugin)
- [Example #2: Alternative.To (Basic Carousel Plugin)](#example-2---alternativeto-basic-carousel-plugin)
- [Example #3: Movie (Advanced Plugin)](#example-3---movie-advance-plugin)
- [Example #4: Quixey (Advanced Carousel Plugin)](#example-4---quixey-advanced-carousel-plugin)
- [Example #5: Dictionary (More Advanced Plugin)](#example-5---dictionary-more-advanced-plugin)
- [Advanced Techniques](#advanced-techniques)
    - [Slurping Multiple Trigger Words](#slurping-multiple-trigger-words...)
    - [Using API Keys](#using-api-keys)
    - [Using the GEO Location API](#using-the-geo-location-api)
    - [Common Code for Spice Endpoints (.pm's)](#common-code-for-spice-endpoints-pms)
    - [Common JavaScript and Handlebars Templates](#common-javascript-and-handlebars-templates)
    - [Using Custom CSS](#using-custom-css)
    - [Using images](#using-images)
- [Common Pitfalls](#common-pitfalls)
    - [Defining Perl Variables and Functions](#defining-perl-variables-and-functions)
- [StyleGuide](#styleguide)
    - [Formatting](#formatting)
    - [Naming Conventions](#naming-conventions)
    - [Do's & Don'ts](#dos--donts)
- [FAQ](#faq)
- [DDG Methods (JavaScript)](#ddg-methods-javascript)
- [Spice Helpers (Handlebars)](#spice-helpers-handlebars)
- [Spice Attributes (Perl)](#spice-attributes-perl)
- [Spice Helper Functions (Perl)](#spice-helper-functions-perl)

-------



##Overview
The Spice frontend is the code that is triggered by the Perl backend (which we learned about in the previous tutorial) for your spice plugin. It mainly consists of a function (the Spice "callback" function) that takes a JSON formatted, API response as its input, specifies which template format you'd like your result to have and uses the data to render a Spice result at the top of the DuckDuckGo search results page.

The Perl part of the plugins go in lib directory: `lib/DDG/Spice/PluginName.pm`, while all of the frontend files discussed below should go in the share directory: `share/spice/plugin_name/`.

**\*\*Note** : The file and folder names must adhere to our [naming conventions](#naming-conventions) in order for everything to function properly.

###Tech
The Spice frontend uses [Handlebars](http://handlebarsjs.com) for templates and includes [jQuery](https://jquery.org) (although it's use is not required). It also allows the use of custom CSS when required.

If you're not already familiar with Handlebars, *please* read the [Handlebars documentation](http://handlebarsjs.com) before continuing on. Don't worry if you don't fully understand how to use Handlebars; the examples will explain it to you. But you should, at the very least, familiarize yourself with Handlebars concepts and terminology before moving on. (Don't worry, it should only take a few minutes to read!)

Below, we will walk you through several examples ranging from simple to complicated, which will explain how to use the template system and make your plugins look awesome.


------------------------


##Example #1 - NPM (Basic Plugin)

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

As mentioned, every plugin requires a Spice callback function, for the *NPM* plugin, the callback is the `ddg_spice_npm()` function that we defined here in *npm.js*. The *NPM* Perl module we wrote specifies this as the callback by using the name of the package `DDG::Spice::NPM` and gives this *ddg_spice_npm* name to the API call so that this funtion will be executed when the API responds using the data returned from the upstream (API) provider as the function's input.

#####npm.js (continued)
```javascript 
if (api_result.error) return
```
Pretty self-explanatory - If the error object in the API result is defined, then break out of the function and don't show any results. In the case of this API, when the error object is defined, it means no results are given, so we have no data to use for a Spice result. 

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

You may notice other plugins also include a css file. For **NPM** the use of CSS wasn't necessary and this is also true for many other plugins. If however CSS is needed it can be added. Please refer to the [Spice FAQ](#faq) for more inforamtion about custom css.

##Example #2 - Alternative.To (Basic Carousel Plugin)
The Alternative.To plugin is very similar to NPM in that it is also relatively basic, however, it uses the new **Carousel** Spice Template. Let's take a look at the code and see how this is done:

######alternative_to.js
```javascript
function ddg_spice_alternative_to(api_result) {
    Spice.render({
        data           : api_result,
        source_name    : 'AlternativeTo',
        source_url     : api_result.Url,
        template_normal: "alternative_to",
        template_frame : "carousel",
        carousel_template_detail: "alternative_to_details",
        carousel_css_id: "alternative_to",
        carousel_items : api_result.Items,
    });
}
```
Just like the NPM plugin, Alternative.To uses `Spice.render()` with most of the same parameters, however, unlike NPM it uses a few new parameters as well:

- `template_frame` is used to tell the Render function that the base template for this plugin will be the **Carousel** template.  
***Note**: This is a template which we have already created and you don't have to worry about creating or modifying.*

- `carousel_template_detail` is an **optional** parameter which specifies the Handlebars template to be used for the Carousel ***detail*** area - the space below the template which appears after clicking a carousel item. For Alternative.To, when a user clicks a carousel item (icon), the detail area appears and provides more information about that particular item. This is similarly used for the [Quixey plugin](https://duckduckgo.com/?q=ios+flight+tracking+app).

- `carousel_css_id` is used to give an `id` to the inner wrapper `div` created by the carousel template. This must be used when any special CSS is written for a plugin using the carousel. It allows any plugin specific CSS to be namespaced eg. `#alternative_to li {…}`, which prevents plugins with custom CSS from interfering with other css that's already loaded.

- `carousel_items` is **required** when using the carousel template. It passes along an array or object to be iterated over by the carousel template. Each of these items becomes the context for the `alternative_to.handlebars` template which defines the content of each `<li>` in the carousel.

----------------------------

Now, let's take a look at the Alternative.To Handlebars templates:
######alternative_to.handlebars
```html
<li class="ddgc_item">
    <img src="/iu/?u={{IconUrl}}">
    <span>{{{condense Name maxlen="25"}}}</span>
</li>
```
This simple template is used to define each of the carousel items. More specifically, it defines each `<li>` in the carousel and defines what the contents will be. In this case we specify an image - the result's icon - and a span tag, which contains the name of the result.

You might notice that we prepend the `<img>`'s `src` url with the string `"/iu/?u="`. This is **required** for any images in your handlebars template. What this line does is proxy the image through our own servers, which ensure the user's privacy (because it forces the request to come from DuckDuckGo instead of the user).

The carousel uses this template by iterating over each item in the object given to `carousel_items` and uses that item as the context of the template.

It's also important to note that the `<li>` has a `class` of `ddgc_item` which is used by our own Carousel CSS to style each item appropriately.

Another important point is that we use `{{{condense Name maxlen="25"}}}` which demonstrates the usage of a Handlebars helper function. In this case, we are using the `condense` function (defined elsewhere, internally) which takes two parameters: `Name` (from `api_result`), which is the string to be shortened and `maxlen="25"` which specifies the length the string will be shortened to. 

Seeing as this is a carousel plugin, which uses the optional carousel details area, it has another Handlebars template which defines the content for that.  Let's have a look at the Alternative.To details template:
######alternative_to_details.handlebars
```html
<div>
    <div><b><a href="{{Url}}">{{Name}}</a></b> <span class="likes">({{Votes}} likes)</span></div>
    <div><i>Description:</i> {{{ShortDescription}}}</div>
    <div><i>Platforms:</i> {{#concat Platforms sep=", " conj=" and "}}{{this}}{{/concat}}</div>
</div>
```
    
This template is also relatively simple. It creates a few `<div>` tags and populates them with relevant information related to the carousel item that was clicked. You'll notice the use of another Handlebars helper function, `concat`. This function takes an array as its first parameter and iterates over each element in the array. For each iteration, `{{#concat}}` sets the context of the block equal to the current array element and then concatenates the content of its block, joining each by the separator string (`sep=`) with the final element separated by the `conj=` string. In this case, if `Platforms` is a list of operating systems: `["windows", "linux", "mac"]`, then `concat` would return: **"widows, linux and mac"**.

Let's take a look at the Alternative.To CSS:

######alternative_to.css
```css
#alternative_to #ddgc_slides li {
    height: 60px !important;
}

#alternative_to #ddgc_slides p{
    height: 0px !important;
}

#alternative_to #ddgc_slides span {
    margin-top: 0px !important;
}   
```
    
This CSS is fairly straightforward, but the most important thing to notice here is that we've namespaced the css using `#alternative_to` and that we have used `!important` to over-ride the default carousel css.


##Example #3 - Movie (Advanced Plugin)
The movie plugin is a more advanced than **NPM** and **Alternative.To**, but most of the logic is in a single function which is used to obtain the most relevant movie from list given to us in `api_result`. Other than that, its relatively easy to understand, so lets start by looking at the Movie plugin's javascript:

######movie.js
```javascript
function ddg_spice_movie (api_result) {

    if (api_result.total === 0) return;

    Spice.render({
        data: api_result,
        source_name: 'Rotten Tomatoes',
        template_normal: "movie",
        template_small: "movie_small",
        force_no_fold: 1
        // source_url, image_url, header set in relevantMovie helper function below
    });
};    
```
    
This plugin has a very simple call to `Spice.render()`, but it slightly differs from other plugin because it not only defines `template_normal`, the default template to be used, but it also defines `template_small` which is the template to be used when this plugin is shown in a stacked state i.e., it is shown below another zero click result, but the content is minimal, preferably a single line of text.

Before looking at the implementation of the Handlebars helper functions lets first take a look at the Movie Spice's Handlebars template to see how the helper functions are used:

######movie.handlebars
```html
{{#relevantMovie}}

    <div id="movie_data_box" {{#if hasContent}}class="half-width"{{/if}}>

        <div>
            {{#if ratings.critics_rating}}
                <span class="movie_data_item">{{ratings.critics_rating}}</span>
                <span class="movie_star_rating">{{{star_rating ratings.critics_score}}}</span>
                <div class="movie_data_description">
                ({{ratings.critics_score}}% critics,
                 {{ratings.audience_score}}% audience approved)
                </div>
            {{else}}
                <span>No score yet...</span>
                <div class="movie_data_description">
                    ({{ratings.audience_score}}% audience approved)
                </div>
            {{/if}}
        </div>

        <div><span class="movie_data_item">MPAA rating:</span>{{mpaa_rating}}</div>
        <div><span class="movie_data_item">Running time:</span>{{runtime}} minutes</div>

        {{#if abridged_cast}}
            <div><span class="movie_data_item">Starring:</span>
                {{#concat abridged_cast sep=", " conj=" and "}}<a href="http://www.rottentomatoes.com/celebrity/{{id}}/">{{name}}</a>{{/concat}}.
            </div>
        {{/if}}

    </div>
    {{#if hasContent}}
        <span>
            {{#if synopsis}}
                {{condense synopsis maxlen="300"}}
            {{else}}
                {{condense critics_consensus maxlen="300"}}
            {{/if}}
        </span>
    {{/if}}

{{/relevantMovie}}
```

The first line of the template demonstrates the use of a [Handlebars block helper](http://handlebarsjs.com/block_helpers.html), `{{#relevantMovie}}` which is defined in **movie.js**. This block helper is important because it sets the context for the rest of the template. In this case we use `{{#relevantMovie}}` to find the most relevant movie from the list of movies in our `api_result`, and then using that single movie object as the context, we use the rest of the template to reference the various properties of the movie and build a result.

If we had implemented this plugin as a Carousel, we would not need to use our relevancy function in this manner becaues the aim wouldn't be to get the single most relevant result. However we chose to implement the movie function in this manner in order to do just that, show the *most* relevant result and so this required the use of a block helper.

It's important you understand the concept of the block helper: outside of the block helper, the context of the template is equal to `api_result`, however, inside the `{{#relevantMovie}}` helper, the context of the template is explicitly set to be the return value of the `{{#relevantMovie}}`. Before looking at the rest of the Handlebars template, let's look at the implementation of `{{#relevantMovie}}`:

######movie.js (continued) - relevantMovie helper
```javascript
/*
 * relevantMovie
 *
 * a block helper that finds the best movie and applies
 * it to the enclosed template block.
 *
 * Sets the source_url, image_url, and header1 for the template
 * based on the best movie.
 *
 */
Handlebars.registerHelper("relevantMovie", function(options) {
    console.log("handlebars helper: relevantMovie, this is:", this);
```

We define the function by using the `Handlebars.registerHelper()` method which takes two parameters: 

1. The name of the helper function we're creating (`"relevantMovie"` in this case)

2. The body of the function (which we then define inline)

***Note:*** when a Handlebars block helper is invoked with no input, `this` (inside the function) refers to the context of the template *at the time the function is invoked*. In this case, we set the `data` parameter to `api_result` in `Spice.render()` so the context of the template is `api_result` when `relevantMovie()` is invoked. This means that inside `relevantMovie()`, `this === api_result`. However, we add a few keys to `api_result` that are needed for other functions, so `api_result` is actually slightly modified, but you can ignore this.

```javascript   
    var ignore = {movie:1, film:1, rotten:1, rating:1, rt:1, tomatoes:1};
    var result, max_score = 0;

    // assign a ranking value for the movie. this isn't a complete sorting value though
    // also we are blindling assuming these values exist
    var score = function(m) {
        var s = m.ratings.critics_score * m.ratings.audience_score;
        if (s > max_score) max_score = s;
        console.log("%d for %s", s, m.title);
        return s; // if any above are undefined, s is undefined
    };
```
A fairly simple function which calculates a score for a given movie based on the combined critics score and audience score. It also keeps track of the highest score so far.
    
```javascript
    // returns the more relevant of the two movies
    var better = function(currentbest, next) {
        console.log("better: comparing %s", next.title);

        return (score(next) > score(currentbest) // if score() returns undefined, this is false, so we're still ok
                    && (next.year < currentbest.year)
                    && DDG.isRelevant(next.title, ignore)) ?
                next : currentbest;
    };
```
As the comment explains, this function simply compares the score of two movies and returns the higher scoring movie. However, it is important to mention the use of the function `DDG.isRelevant()`. This is a special internal function which compares the input string to the current search query (i.e., the one that triggered this plugin), to see how relevant the string is with respect to the words in the query. `DDG.isRelevant()` also takes an **optional** second parameter which is an object containing sets of keys with a value of 1. The keys of this object, defined by the developer, will explicitly be ignored when comparing the query string against the candidate string. In our case we are comparing the title of the movie we are currently considering, `next.title`, against the search query and we explicitly ignore a set of words - mostly trigger words for the plugin - as defined above: `var ignore = ["movie", "film", "rotten", "rating", "rt", "tomatoes"];`.

```javascript
    result = DDG_bestResult(this.movies, better);

    // favor the first result if the max score is within 1% of the score for the first result
    if (result !== this.movies[0] && Math.abs(score(this.movies[0]) - max_score) / max_score < 0.1) {
        result = this.movies[0];
    }
```
    
Now that we have our functions defined, we use them to find the most relevant movie. In order to do so, we use the function `DDG_bestResult()` which is another internal function that takes two parameters, a list and a comparison function. In our case we use `DDG_bestResult()` to iterate over our the list of movies, `this.movies` using the function `better()` which we defined above.
    
```javascript
    // make the movie's info available to the zero click template
    // by setting spice value in the ddh (duckduckhack) object

    var checkYear = function(year) {
        if(year) {
            return " (" + result.year + ")";
        }
        return "";
    };

    this.ddh.source_url = result.links.alternate;
    this.ddh.header1 = result.title + checkYear(result.year);

    if (result.posters.thumbnail && result.posters.thumbnail.indexOf("poster_default.gif") == -1) {
        this.ddh.image_url = result.posters.thumbnail;
    }

    if ((result.synopsis && result.synopsis.length) ||
        (result.critics_consensus && result.critics_consensus.length)){
        result.hasContent = true;
    }
```
Now that we have selected our most relevant result, we use it to set the values of the Zero Click Box Header, Source URL and Image URL. As previously mentioned, we slightly modify `api_result` when we set it as the context of the template. What we actually do is append the `ddh` object to `api_result`, which lets us modify the properties of `Spice.render()`.

```javascript
    // invoke the body of the block with the relevant movie as the context
    return options.fn(result);
});
```
This last line is **very** important. Here, we are using the Handlebars function `options.fn()` which is a special function used specifically to change the context of the template, ***within the body of the block helper***, to the value of the function's input. So in this case, within `{{relevantMovie}} … {{/relevantMovie}}` the context of the template is equal to the `result` object created by `relevantMovie()` which allows us to reference the properties of the `result` object, in our Handlebars template. With that in mind, lets move on and see the rest of the **Movie.handlebars**:

######movie.handlebars (again...)
```html
{{#relevantMovie}}

    <div id="movie_data_box" {{#if hasContent}}class="half-width"{{/if}}>

        <div>
            {{#if ratings.critics_rating}}
                <span class="movie_data_item">{{ratings.critics_rating}}</span>
                <span class="movie_star_rating">{{{star_rating ratings.critics_score}}}</span>
                <div class="movie_data_description">
                ({{ratings.critics_score}}% critics,
                 {{ratings.audience_score}}% audience approved)
                </div>
            {{else}}
                <span>No score yet...</span>
                <div class="movie_data_description">
                    ({{ratings.audience_score}}% audience approved)
                </div>
            {{/if}}
        </div>

        <div><span class="movie_data_item">MPAA rating:</span>{{mpaa_rating}}</div>
        <div><span class="movie_data_item">Running time:</span>{{runtime}} minutes</div>

        {{#if abridged_cast}}
            <div><span class="movie_data_item">Starring:</span>
                {{#concat abridged_cast sep=", " conj=" and "}}<a href="http://www.rottentomatoes.com/celebrity/{{id}}/">{{name}}</a>{{/concat}}.
            </div>
        {{/if}}

    </div>
    {{#if hasContent}}
        <span>
            {{#if synopsis}}
                {{condense synopsis maxlen="300"}}
            {{else}}
                {{condense critics_consensus maxlen="300"}}
            {{/if}}
        </span>
    {{/if}}

{{/relevantMovie}}
```

Inside the `{{relevantMovie}}` block helper, the template is pretty simple - we create a few `div`'s and reference properties of the context just like we did in **NPM** and **Alternative.To**. We also use a few more Handlebars helper functions, `star_rating` which we define in **movie.js**, `concat` and `condense`, which we've already discussed, and another block helper, `{{#if}}` (a default Handlebars helper) which should be self-explanatory. We use the `{{if}}` helper to check if a variable exists in the current context. However, this block helper, unlike `{{#relevantMovie}}`, ***doesn't*** change the context of the template inside its block. Rather, it adds the contents of its own block to the template if the input variable exists. As well, the `{{if}}` block allows the use of the optional `{{else}}` block which lets you add alternate content to the template when the input variable does not exist.

Moving on, let's take a look at the implementation of `star_rating`:
    
######movie.js (continued) - star_rating helper

```javascript
/* star rating */
Handlebars.registerHelper("star_rating", function(score) {
    var r = (score / 20) - 1;
    var s = "";

    if (r > 0) {
        for (var i = 0; i < r; i++) {
            s += "&#9733;";
        }
    }

    if (s.length == 0) {
        s = "0 Stars";
    }

    return s;
});
```

As you can see this is a pretty simple function, it takes a number as input, and use that to calculate a star rating. Then creates a string of ASCII stars and returns it to the template which will then be rendered by the browser to show a star rating of the movie.

Now let's take a look at the implementation of `rating_adjective`:

######movie.js (continued) - rating_adjective helper
```javascript
/*
 * rating_adjective
 *
 * help make the description of the movie gramatically correct
 * used in reference to the rating of the movie, as in
 *   'an' R rated movie, or
 *   'a'  PG rated movie
 */
Handlebars.registerHelper("rating_adjective", function() {
    return (this.mpaa_rating === "R"
         || this.mpaa_rating === "NC-17"
         || this.mpaa_rating === "Unrated") ?  "an" :"a";
});
```

Again, this is a fairly simply function which simply returns either "a" or "an" based on the rating of the movie.

Now that you've seen a more advanced plugin and understand how to use Handlebars helpers, lets look at another advanced plugin example.

##Example #4 - Quixey (Advanced Carousel Plugin)
The Quixey plugin is one of our more advanced carousel plugins which uses a considerable amount of Handlebars helpers and similarly to the **Movie** plugin has a relevancy checking component. Let's begin by taking a look at the Quixey plugin's JavaScript:

######quixey.js
```javascript
// spice callback function
function ddg_spice_quixey (api_result) {

    if (api_result.result_count == 0) return;

    var q = api_result.q.replace(/\s/g, '+');
    var relevants = getRelevants(api_result.results);

    if (!relevants) return;

    Spice.render({
        data: api_result,
        source_name: 'Quixey',
        source_url: 'https://www.quixey.com/search?q=' + q,
        header1: api_result.q + ' (App Search)',
        force_big_header: true,

        more_logo: "quixey_logo.png",

        template_frame: "carousel",
        template_normal: "quixey",
        carousel_css_id: "quixey",
        carousel_template_detail: "quixey_detail",
```

Similarly to **Alternative.To**, the Quixey plugin uses the carousel, and sets values for all the required carousel-specific properties. However, this plugin also uses the `force_big_header` property to create a ZeroClick header and subsquently sets the value of the header text, `header1`. Also, the `more_logo` property is set, which allows a custom image to be used instead of the `source_name` text.  

One important difference about Quixey is the use of our own `getRelevants()` function (defined below in **Quixey.js**), which is used to check for relevant results before calling `Spice.render()`. Unlike the **Movie** plugin, we are required to get relevant results in this manner (i.e., outside the template) so that only the results we want included in the carousel are passed on to the **quixey.handlebars** template.

Moving on, let's take a look at the implementation of the `getRelevants()` helper:

######quixey.js (continued) - getRelevants function
```javascript
// Check for relevant app results
function getRelevants (results) {
        
    var res,
        apps = [],
        backupApps = [],
        categories = /action|adventure|arcade|board|business|casino|design|developer tools|dice|education|educational|entertainment|family|finance|graphics|graphics and design|health and fitness|kids|lifestyle|medical|music|networking|news|photography|productivity|puzzle|racing|role playing|simulation|social networking|social|sports|strategy|travel|trivia|utilities|video|weather/i,
        skip_words = ["app", "apps", "application", "applications", "android", "droid", "google play store", "google play", "windows phone", "windows phone 8", "windows mobile", "blackberry", "apple app store", "apple app", "ipod touch", "ipod", "iphone", "ipad", "ios", "free", "search", "release", release date"];
        
    for (var i = 0; i < results.length; i++) {

        app = results[i];

        // check if this app result is relevant
        if (DDG.isRelevant(app.name.toLowerCase(), skip_words)) {
            apps.push(app);
        } else if (app.hasOwnProperty("short_desc") &&
                   DDG.isRelevant(app.short_desc.toLowerCase(), skip_words)) {
                        backupApps.push(app);
        } else if (app.custom.hasOwnProperty("category") &&
                   DDG.isRelevant(app.custom.category.toLowerCase(), skip_words)) {
                        backupApps.push(app);
        } else{
            continue;
        }
    }

    // Return highly relevant results
    if (apps.length > 0) {
        res = apps;
    }

    // Return mostly relevant results
    else if (backupApps.length > 0) {
        res = backupApps;
    }

    else {
        // No relevant results,
        // check if it was a categorical search
        // Eg."social apps for android"
        var q = DDG.get_query();
        res = q.match(categories) ? results : null;
    }
    return res;
});
```

We begin by defining the function and its input, `results` which is an array of apps. Then we define some variables, notable we define `skip_words`, which we will use later for a call to the `isRelevant()` function we discussed earlier. Then, we move onto a `for` loop which does the bulk of the work by iterating over ever app in the `results` array and applies a series of `isRelevant()` checks to see if either the app name, short description or category are relevant to the search query. If the name is considered to be relevant we add it to the `apps` array which contains all the relevant app results. If the name isn't relevant but the description or category is, we add it to the `backupApps` array, because we might need them later. If none of those properties are considered relevant we simply exclude that app from the set of apps that will be displayed to the user.

After we've checked every app we check to see if there were any relevant apps and if so, we show them to the user. Otherwise, we check our `backupApps` array to see if there were any apps who might be relevant and show those to the user. Failing that, we check if the search was for an app category and if so, we return all the results because the Quixey API is assumed to have relevant results. 

Before looking at the implementation of the remaining Quixey Handlebars helpers, lets look at the template to see how the helpers are used:

######quixey.handlebars
```html
<li class="ddgc_item"> {{! width set in setup() }}
    <p><img src="{{{icon_url}}}" /></p>
    <span>{{{condense name maxlen="40"}}}</span>
</li>
```

This template is very simple, it creates an `<li>` with an `<img>` tag, for the resulting app icon and a `<span>` tag for the app name. You may also notice that unlilke **Alternative.To**, we placed the `<img>` tag inside `<p>` tags. We do this to automatically center and align the images, through the use of carousel specific CSS that we wrote, because the images aren't all the same size and would otherwise be missalligned. So, if the images for your plugin aren't the same size, simply wrap them in `<p>` tags and the carousel will take care of the rest. If not, simply ignore the use of the `<p>` tags.

Now let's take a look at the Quixey `carousel_template_detail` template. This template is more advanced, but most of the content is basic HTML which is populated by various `api_result` properties and Handlebars helpers:

######quixey_detail.handlebars (continued)
```html
<div id="quixey_preview" style="width: 100%; height: 100%;" app="{{id}}">
    <div class="app_info">
        <a href="{{{url}}}" class="app_icon_anchor">
            <img src="{{{icon_url}}}" class="app_icon">
        </a>
        <div class="name_wrap">
            <a href="{{url}}" class="name" title="{{name}}">{{name}}</a>
```

Here we create the outer div that wraps the content in the detail area. Note the use of HTML ids and classes - this is to make the css more straightforward, modular and understandable.

######quixey_detail.handlebars (continued)
```html
            {{#if rating}}
                <div title="{{rating}}" class="rating">
                    {{#loop rating}}
                        <img src="{{quixey_star}}" class="star"></span>
                    {{/loop}}
                </div>
            {{/if}}
```

Here we use the `{{#if}}` block helper and nested inside that, we use our own `{{#loop}}` block helper (defined internally), which simply counts from 0 to the value of its input, each time applying the content of its own block. In this example, we use it to create a one or more star images to represent the app's rating.
 
######quixey_detail.handlebars (continued) 
```html
            <div class="price">{{pricerange}}</div>
            <div class="app_description">{{{short_desc}}}</div>
            <div id="details_{{id}}" class="app_details">
                <div class="app_editions">
                    {{#each editions}}
                        <div class="app_edition" title="{{name}} - Rating: {{rating}}">
                            <a href="{{{url}}}" class="app_platform">
                                {{#with this.platforms.[0]}}
                                <img src="{{platform_icon icon_url}}" class="platform_icon">
                                {{/with}}
                                {{platform_name}}
                                {{#if ../hasPricerange}}
                                     - {{price cents}}
                                {{/if}}
                            </a>
                        </div>
                    {{/each}}
                </div>
            </div>
        </div>
    </div>
    <div class="clear"></div>
</div>
```

Here, we create a few more `<div>`'s and then we use another block helper, `{{#each}}`, which takes an array as input, and iterates over each of the array's elements, using them as the context for the `{{#each}}` block. Nested within the `{{#each}]` helper, we also use the `#{{with}}` block helper, which takes a single object as input, and applies that object as the context for its block. One more interesting thing to note is the input we give to the `{{#if}}` block nested in our `{{#each}}` block. We use the `../` to reference the parent template's context.  

Now that we've seen the template and the helpers we're using, let's take a look at how they're all implemented:

######quixey.js (continued) -  qprice function
```javascript
// format a price
// p is expected to be a number
function qprice(p) {
    if (p == 0) {    // == type coercion is ok here
        return "FREE";
    }
    
    return "$" + (p/100).toFixed(2).toString();
}
```

This is a simple function that formats a price. We don't register it as a helper because we don't need to use this function directly in our templates, however our helper functions do use this function `qprice()` function.

######quixey.js (continued) -  price helper
```javascript
// template helper for price formatting
// {{price x}}
Handlebars.registerHelper("price", function(obj) {
    return qprice(obj);
});
```

This helper function is relatively simple, it takes a number as input, calls the `qprice()` function we just saw, and returns it's output to the template. It essentially abstracts our `qprice()` function into a Handlebars helper. We do this because the next function we'll see also uses `qprice()` and its simply easier to call it as a locally defined function, rather than register it as a helper and then use the `Handlebars.helpers` object to call the `qprice()` function.

######quixey.js (continued) -  pricerange helper
```javascript
// template helper to format a price range
Handlebars.registerHelper("pricerange", function(obj) {
   
    if (!this.editions)
        return "";

    var low  = this.editions[0].cents;
    var high = this.editions[0].cents;
    var tmp, range, lowp, highp;

    for (var i in this.editions) {
        tmp = this.editions[i].cents;
        if (tmp < low) low = tmp;
        if (tmp > high) high = tmp;
    }

    lowp = qprice(low);

    if (high > low) {
       highp = qprice(high);
       range = lowp + " - " + highp;
       this.hasPricerange = true;
    } else {
        range = lowp;
    }
   
    return range;
});
```

This function is a little more complex, it takes an object as input, iterates over the objects keys, and records the highest and lowest prices for the app. Then, it verifies that the range has different high and low values. If not, it simply returns the low price, formatted using our `qprice()` function. Otherwise, it creates a string indicating the range and formats the values with `qprice()`.

######quixey.js (continued) -  platform_icons helper
```javascript
// template helper to replace iphone and ipod icons with
// smaller 'Apple' icons
Handlebars.registerHelper("platform_icon", function(icon_url) {
    if (this.id === 2004 || this.id === 2015) {
        return "https://icons.duckduckgo.com/i/itunes.apple.com.ico";
    }

    return "/iu/?u=" + icon_url + "&f=1";
});
```

Another very simple helper function, the `platform_icon()` function simply checks if its input is equal to `2005` or `2015` and if so returns a special url for the platform icon. If not, it returns the originial icon url but adds our proxy redirect, `/iu/?u=` as previously discussed.

######quixey.js (continued) -  platform_name helper
```javascript
// template helper that returns and unifies platform names
Handlebars.registerHelper("platform_name", function() {
    var name;
    var platforms = this.platforms;

    name = platforms[0].name;

    if (platforms.length > 1) {
        switch (platforms[0].name) {
            case "iPhone" :
            case "iPad" :
                name = "iOS";
                break;

            case "Blackberry":
            case "Blackberry 10":
                name = "Blackberry";
                break;
        }
    }

    return name;
});
```

This helper is also quite simple, it is used to return a platform name and someties also unifies the platform name when multiple platforms exist for an app. If the app is available for both 'iPhone' and 'iPad', the `switch()` will catch this and indicate the app is availabe for "iOS".

######quixey.js (continued) -  quixey_star helper
```javascript
// template helper to give url for star icon
Handlebars.registerHelper("quixey_star", function() {
    return DDG.get_asset_path("quixey", "star.png").replace("//", "/");
});
```

This helper is also very simple, but it is important because it uses the `DDG.get_asset_path()` function which returns the URI for an asset stored in a plugin's share folder. This is necessary because Spice plugins and their content are versioned internally. So the URI returned by this function will contain the proper version number, which is required to access any assets.

##Example #5 - Dictionary (More Advanced Plugin)
The dictionary plugin is a more advanced plugin than the previous examples, because it requires multiple endpoints (which means it has multiple perl modules -`.pm` files) in order to function properly. You will notice the `definition` endpoint is a subdirectory of the `dictionary` directory: `zeroclickinfo-spice/share/spice/dictionary/definition/`. In the case of the **Dictionary** plugin, its Perl modules work together as one plugin, however if the other endpoints worked seperately from the `definition` endpoint, such as they do in the **[Last.FM](https://github.com/duckduckgo/zeroclickinfo-spice/tree/spice2/share/spice/lastfm)** plugin, they too would each have their own subdirectories and would also each have their own respective JavaScript, Handlebars and CSS files. 

To begin, lets look at the first callback function definition in the Dictionary javascript:

######dictionary_definition.js
```javascript
// Description:
// Shows the definition of a word.
//
// Dependencies:
// Requires SoundManager2.
//
// Commands:
// define dictionary - gives the definition of the word "dictionary."
//
// Notes:
// ddg_spice_dictionary_definition - gets the definitions of a given word (e.g. noun. A sound or a combination of sounds).
// ddg_spice_dictionary_pronunciation - gets the pronunciation of a word (e.g. wûrd).
// ddg_spice_dictionary_audio - gets the audio file.
// ddg_spice_dictionary_reference - handles plural words. (Improve on this in the future.)
```

The comments at the beginning of the file explain what the various callbacks are for. Each of these callback functions is connected to a different endpoint, meaning they each belong to a different Perl module. As you can see, the name of each callback corellates to the name of the perlmodule. So `dictionary_definition()` is the callback for `DDG::Spice::Dictionary::Definition`, likewise `dictionary_audio` is for `DDG::Spice::Dictionary::Audio`, etc.

Each of these endpoints are used to make different API calls (either to a different endpoint or possibly even a different API altogether), which can only be done by creating a different Perl module for each endpoint. We can make these endpoints work together for a given plugin by using the jQuery `getScript()` function which makes an ajax call to a given endpoint, which results in a call to that endpoint's callback function. This function needs to be defined before it is called, so the Dictionary plugin defines all **four** callback functions in **dictionary_definition.js**

Moving on, let's take a look at the implementation of the `Spice.render()` call and the `dictionary_definition()`  callback:

######dictionary_definition.js (continued) - dictionary_definition callback
```javascript
// Dictionary::Definition will call this function.
// This function gets the definition of a word.
function ddg_spice_dictionary_definition (api_result) {
    "use strict";
    var path = "/js/spice/dictionary";

    // We moved Spice.render to a function because we're choosing between two contexts.
    var render = function(context, word, otherWord) {
        Spice.render({
            data              : context,
            header1           : "Definition (Wordnik)",
            force_big_header  : true,
            source_name       : "Wordnik",
            source_url        : "http://www.wordnik.com/words/" + word,
            template_normal   : "dictionary_definition"
        });

        // Do not add hyphenation when we're asking for two words.
        // If we don't have this, we'd have results such as "black• hole".
        if(!word.match(/\s/)) {
            $.getScript(path + "/hyphenation/" + word);
        }

        // Call the Wordnik API to display the pronunciation text and the audio.
        $.getScript(path + "/pronunciation/" + otherWord);
        $.getScript(path + "/audio/" + otherWord);
    };
```

We begin by wrapping the `Spice.render()` call in a function which also does a little extra work. Specifically after rendering the result it calls the Wordnik API, this time using two different API endpoints. The first gets the pronounciation text, the second gets the audio file for the pronounciation of the word. As mentioned these endpoints are used to work together as one plugin so using the returns from the seperate API calls we construct one dictionary plugin result which contains the word definition, the pronounciation text and the audio recording of the pronounciation.

The reason for wrapping the `Spice.render()` call in a function is because we need to be able to call our `render()` function from both the `dictionary_defintion()` callback as well as the `dictionary_reference()` callback, as you will see below:

######dictionary_definition.js (continued) - dictionary_definition callback
```javascript
    // Expose the render function.
    ddg_spice_dictionary_definition.render = render;

    // Prevent jQuery from appending "_={timestamp}" in our url when we use $.getScript.
    // If cache was set to false, it would be calling /js/spice/dictionary/definition/hello?_=12345
    // and that's something that we don't want.
    $.ajaxSetup({
        cache: true
    });

    // Check if we have results we need.
    if (api_result && api_result.length > 0) {

        // Wait, before we display the plugin, let's check if it's a plural
        // such as the word "cacti."
        var singular = api_result[0].text.match(/^(?:A )?plural (?:form )?of <xref>([^<]+)<\/xref>/i);

        // If the word is plural, then we should load the definition of the word
        // in singular form. The definition of the singular word is usually more helpful.
        if(api_result.length === 1 && singular) {
            ddg_spice_dictionary_definition.pluralOf = api_result[0].word;
            $.getScript(path + "/reference/" + singular[1]);
        } else {
            // Render the plugin if everything is fine.
            render(api_result, api_result[0].word, api_result[0].word);
        }
    }
};
```

After defining the `render()` function we give the function a `render` property, `ddg_spice_dictionary_definition.render = render;` (so we can access the `render()` function from other callbacks) and then move on to check if we actually have any definition results returned from the API. If so, we then check if the queried word is a plural word and if so, make another API call for the singular version of the queried word. This call, `$.getScript(path + "/reference/" + singular[1]);` will result in calling the `dictionary_reference()` callback which eventually calls our `render()` function to show our Spice result on the page. If the word is not a plural, we instead immediately call the `render()` function and display our result.

**\*\*Note:** More info on the jQuery `$.getScript()` method is available [here](http://api.jquery.com/jQuery.getScript/).

######dictionary_definition.js (continued) - dictionary_reference callback
```javascript
// Dictionary::Reference will call this function.
// This is the part where we load the definition of the
// singular form of the word.
function ddg_spice_dictionary_reference (api_result) {
    "use strict";

    var render = ddg_spice_dictionary_definition.render;

    if(api_result && api_result.length > 0) {
        var word = api_result[0].word;

        // We're doing this because we want to say:
        // "Cacti is the plural form of cactus."
        api_result[0].pluralOf = word;
        api_result[0].word = ddg_spice_dictionary_definition.pluralOf;

        // Render the plugin.
        render(api_result, api_result[0].word, word);
    }
};
```

In this relatively simple callback, we begin by using the previously defined render property of the `dictionary_definiton()` function to give this callback access to the `render()` function we defined at the beginning of `quixey.js`. Then we confirm that this callback's `api_result` actually recieved the singular form of the originially searched query. If so, we add the singular and plural form of the word to our `api_result` object so we can check for and use them later in our Handlebars template.

######dictionary_definition.js (continued) - dictionary_hyphenation callback
```javascript
// Dictionary::Hyphenation will call this function.
// We want to add hyphenation to the word, e.g., hello -> hel•lo.
function ddg_spice_dictionary_hyphenation (api_result) {
    "use strict";

    var result = [];
    if(api_result && api_result.length > 0) {
        for(var i = 0; i < api_result.length; i += 1) {
            result.push(api_result[i].text);
        }
        // Replace the, rather lame, non-hyphenated version of the word.
        $("#hyphenation").html(result.join("•"));
    }
};
```

This callback is also fairly simple. If the API returns a result for the hyphenated version of the word, we loop over the response to get the various parts of the word, then join them with the dot character "•", and inject the text into the HTML of the **#hyphenation** `<div>` using jQuery.

######dictionary_definition.js (continued) - dictionary_pronunciation callback
```javascript
// Dictionary::Pronunciation will call this function.
// It displays the text that tells you how to pronounce a word.
function ddg_spice_dictionary_pronunciation (api_result) {
    "use strict";

    if(api_result && api_result.length > 0 && api_result[0].rawType === "ahd-legacy") {
        $("#pronunciation").html(api_result[0].raw);
    }
};
```

Similarly to the `dictionary_hyphenation()` callback, this callback receives a phonetic spelling of the queried word and injects it into the Spice result by using jQuery as well to modify the HTML of the **#pronounciation** `<div>`.
 
######dictionary_definition.js (continued) - dictionary_audio callback
```javascript
// Dictionary::Audio will call this function.
// It gets the link to an audio file.
function ddg_spice_dictionary_audio (api_result) {
    "use strict";

    var isFailed = false;
    var url = "";
    var icon = $("#play-button");

    // Sets the icon to play.
    var resetIcon = function() {
        icon.removeClass("widget-button-press");
    };

    // Sets the icon to stop.
    var pressIcon = function() {
        icon.addClass("widget-button-press");
    };
```

This callback begins by defining a few simple functions and some variables to used below. Again, jQuery is used to modify the DOM as needed in this callback.  

```javascript
    // Check if we got anything from Wordnik.
    if(api_result && api_result.length > 0) {
        icon.html("▶");
        icon.removeClass("widget-disappear");

        // Load the icon immediately if we know that the url exists.
        resetIcon();

        // Find the audio url that was created by Macmillan (it usually sounds better).
        for(var i = 0; i < api_result.length; i += 1) {
            if(api_result[i].createdBy === "macmillan" && url === "") {
                url = api_result[i].fileUrl;
            }
        }

        // If we don't find Macmillan, we use the first one.
        if(url === "") {
            url = api_result[0].fileUrl;
        }
    } else {
        return;
    }
```

The callback then verifies the API returned a pronunciation of the queried word and if so, injects a play icon, "▶" into the **#play-button** `<button>` and grabs the url for the audio file from the API response.

```javascript
    // Load the sound and set the icon.
    var isLoaded = false;
    var loadSound = function() {
        // Set the sound file.
        var sound = soundManager.createSound({
            id: "dictionary-sound",
            url: "/audio/?u=" + url,
            onfinish: function() {
                resetIcon();
                soundManager.stopAll();
            },
            ontimeout: function() {
                isFailed = true;
                resetIcon();
            },
            whileplaying: function() {
                // We add this just in case onfinish doesn't fire.
                if(this.position === this.durationEstimate) {
                    resetIcon();
                    soundManager.stopAll();
                }
            }
        });

        sound.load();
        isLoaded = true;
    };
```

Here, we define a function, `loadSound()` that uses the [**SoundManager**](http://www.schillmania.com/projects/soundmanager2/) JavasScript library to load the audio file and also allows us to easily control the playing of the audio. An important piece of this `loadSound()` function is the use of our audio proxy: `url: "/audio/?u=" + url`. Similarly to any images used in a plugin, any audio files must also be proxied through DuckDuckGo to ensure our users' privacy.

**\*\*Note:** The use of the SoundManager library for this plugin shouldn't be taken lightly. We chose to use a JavaScript library to ensure cross-browser compatabilty but the use of 3rd party libraries is not something we advocate, however since this was an internally written plugin, we decided to use the SoundManager library for this plugin as well as all others which utilize audio (eg. [Forvo](https://duckduckgo.com/?q=pronounce+awesome)).

```javascript
    // Initialize the soundManager object.
    var soundSetup = function() {
        window.soundManager = new SoundManager();
        soundManager.url = "/soundmanager2/swf/";
        soundManager.flashVersion = 9;
        soundManager.useFlashBlock = false;
        soundManager.useHTML5Audio = false;
        soundManager.useFastPolling = true;
        soundManager.useHighPerformance = true;
        soundManager.multiShotEvents = true;
        soundManager.ontimeout(function() {
            isFailed = true;
            resetIcon();
        });
        soundManager.beginDelayedInit();
        soundManager.onready(loadSound);
    };
```

As the comment explains, this function is used to initialize SoundManager so we can then use it to control the audio on the page.

```javascript
    // Play the sound when the icon is clicked. Do not let the user play
    // without window.soundManager.
    icon.click(function() {
        if(isFailed) {
            pressIcon();
            setTimeout(resetIcon, 1000);
        } else if(!icon.hasClass("widget-button-press") && isLoaded) {
            pressIcon();
            soundManager.play("dictionary-sound");
        }
    });
```

Here we define a click handler function using jQuery. Based on the state of the sound widget, `isFailed`, the handler either 

```javascript
    // Check if soundManager was already loaded. If not, we should load it.
    // See http://www.schillmania.com/projects/soundmanager2/demo/template/sm2_defer-example.html
    if(!window.soundManager) {
        window.SM2_DEFER = true;
        $.getScript("/soundmanager2/script/soundmanager2-nodebug-jsmin.js", soundSetup);
    } else {
        isLoaded = true;
    }
};
```

Now that we've seen how all the API callback functions are implemented, lets take a look at the Handlebars to see what helpers are used and how the display is built:

```html
<div>
    <b id="hyphenation">{{this.[0].word}}</b>
    {{#if this.[0].pluralOf}}
        <span> is the plural form of {{this.[0].pluralOf}}</span>
    {{/if}}
    <span id="pronunciation"></span>
    <button id="play-button" class="widget-button widget-disappear"></button>
</div>
{{#each this}}
    <div class="definition">
        <i>{{part partOfSpeech}}</i>
        <span>{{{format text}}}</span>
    </div>
{{/each}}
```

As you can see, the template and layout for the dictionary Spice is relatively simple. We begin by placing the term to be defined in a `<b>` tag. As you can see, to access the element from the context, we need to use a special array notation: `this.[0].word`, where the `[0]` indicates the first element in the array.

We then check if the `this.[0].pluralOf` variable has been set. As you may recall, we set this variable in the `dictionary_reference()` callback function, after checking in the `dictionary_definition()` callback if the queried term is a plurl. If the `pluralOf` variable has been set we then create a `<span>` tag and for a sentence to indicate which word the queried word is a plural of.

Then the template creates two empty elements, a `<span>` tag to contain the phonetic spelling, which may or may not be populated by our `dictionary_pronunciation()` callback, depending on the wether or not the API has a phonetic spelling for the queried word. Similarly we create an empty `<button>` tag to play an audio recording of the word pronunciation which is potentially populated by the `dictionary_audio()` callback, again if the API has an audio file for the queried word's pronunciation.

The template then uses a Handlebars `{{#each}}` helper to iterate over the context (because it is an array in this case, not an object) and for each element creates a snippet of text indicating the usage of the term (eg. noun, verb) and provides the definition of the term. This `{{#each}}` helper also uses two Handlebars helpers defined in **dictionary_definition.js**, `{{part}}` and `{{format}}`. Lets take a look at how they're implemented:

######dictionary_definition.js (continued) - part helper
```javascript
// We should shorten the part of speech before displaying the definition.
Handlebars.registerHelper("part", function(text) {
    "use strict";

    var part_of_speech = {
        "interjection": "interj.",
        "noun": "n.",
        "verb-intransitive": "v.",
        "verb-transitive": "v.",
        "adjective": "adj.",
        "adverb": "adv.",
        "verb": "v.",
        "pronoun": "pro.",
        "conjunction": "conj.",
        "preposition": "prep.",
        "auxiliary-verb": "v.",
        "undefined": "",
        "noun-plural": "n.",
        "abbreviation": "abbr.",
        "proper-noun": "n."
    };

    return part_of_speech[text] || text;
});
```

As the comment explains, this simple helper function is used to shorten the "part of speech" word returned by the API.

######dictionary_definition.js (continued) - format helper
```javascript
// Make sure we replace xref to an anchor tag.
// <xref> comes from the Wordnik API.
Handlebars.registerHelper("format", function(text) {
    "use strict";

    // Replace the xref tag with an anchor tag.
    text = text.replace(/<xref>([^<]+)<\/xref>/g,
                "<a class='reference' href='https://www.wordnik.com/words/$1'>$1</a>");

    return text;
});
```

This helper is used to create hyperlinks within the word definition text. The Wordnik API we are using for this plugin provides definitions which often contain words or phrases that are wrapped in `<xref>` tags indicating that Wordnik also has a definition for that word or phrase. This helper is used to replace the `<xref>` tags with `<a>` tags that link to a search for that particular word on **Wordnik.com**.

Now that we have seen the Handlebars template and all looked over all the JavaScript related to the dictionary plugin, lets take a look at the CSS used to style the display of the result:

######dictionary_definition.css
```css
.widget-button {
    background: #eee; /* Old browsers */
    background: #eee -moz-linear-gradient(top, rgba(255,255,255,.1) 0%, rgba(0,0,0,.1) 100%); /* FF3.6+ */
    background: #eee -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(255,255,255,.1)), color-stop(100%,rgba(0,0,0,.1))); /* Chrome,Safari4+ */
    background: #eee -webkit-linear-gradient(top, rgba(255,255,255,.1) 0%,rgba(0,0,0,.1) 100%); /* Chrome10+,Safari5.1+ */
    background: #eee -o-linear-gradient(top, rgba(255,255,255,.1) 0%,rgba(0,0,0,.1) 100%); /* Opera11.10+ */
    background: #eee -ms-linear-gradient(top, rgba(255,255,255,.1) 0%,rgba(0,0,0,.1) 100%); /* IE10+ */
    background: #eee linear-gradient(top, rgba(255,255,255,.1) 0%,rgba(0,0,0,.1) 100%); /* W3C */

    border-left: 1px solid #ccc;
    border-right: 0;
    border-top: 0;
    border-bottom: 0;

    -webkit-border-radius: 4px;
    -moz-border-radius: 4px;
    border-radius: 4px;

    color: #444;
    display: inline-block;
    font-size: 11px;
    font-weight: bold;
    text-decoration: none;
    text-shadow: 0 1px rgba(255, 255, 255, .75);
    cursor: pointer;
    line-height: normal;
    padding: 2px 5px;
    vertical-align: text-bottom;
}

.widget-button-press {
    border-color: #666;
    background: #ccc; /* Old browsers */
    background: #ccc -moz-linear-gradient(top, rgba(255,255,255,.25) 0%, rgba(10,10,10,.4) 100%); /* FF3.6+ */
    background: #ccc -webkit-gradient(linear, left top, left bottom, color-stop(0%,rgba(255,255,255,.25)), color-stop(100%,rgba(10,10,10,.4))); /* Chrome,Safari4+ */
    background: #ccc -webkit-linear-gradient(top, rgba(255,255,255,.25) 0%,rgba(10,10,10,.4) 100%); /* Chrome10+,Safari5.1+ */
    background: #ccc -o-linear-gradient(top, rgba(255,255,255,.25) 0%,rgba(10,10,10,.4) 100%); /* Opera11.10+ */
    background: #ccc -ms-linear-gradient(top, rgba(255,255,255,.25) 0%,rgba(10,10,10,.4) 100%); /* IE10+ */
    background: #ccc linear-gradient(top, rgba(255,255,255,.25) 0%,rgba(10,10,10,.4) 100%); /* W3C */ }


    /* Fix for odd Mozilla border & padding issues */
    button::-moz-focus-inner,
    input::-moz-focus-inner {
    border: 0;
    padding: 0;
}

.widget-disappear {
  display: none;
}

#play-icon {
  line-height: normal;
}

.definition em {
    font-style: italic;
}
```

Understanding this CSS isn't terribly important in this case because most of it has been borrowed from the [Skeleton](http://getskeleton.com) framework's button styling. Most of this CSS is specific to the `.widget-button` class and is used to style the look of the play button. Also its worth mentioning that this particular CSS has been written to be very cross-browser compatible as you can see by the comments which indicate the browsers each line has been written for.

As you can see, the Dictionary plugin is one of the most involved Spice plugins we have due to its use of multiple endpoints and their respective callback functions. Most plugins however shouldn't need to be so complex in order to function, so we greatly prefer that plugins are built as simple and straightforward as possible.

##Conclusion
Now that you have completed the walk through you should have the required knowledge to go on and build your own plugins. More information about writing plugins is available below.

------

##Advanced Techniques

###Slurping Multiple Trigger Words
Some plugins, such as the [**Zanran**](https://github.com/duckduckgo/zeroclickinfo-spice/blob/spice2/lib/DDG/Spice/Zanran.pm) and [**ExpandURL**](https://github.com/duckduckgo/zeroclickinfo-spice/blob/spice2/lib/DDG/Spice/ExpandURL.pm) plugins require a large list of trigger words due to the nature of the plugin. However, listing all those triggers in the Perl code can make it very difficult to read. As an easy fix, we have opted to list all the possible trigger words for each plugin in a `triggers.txt` file located in each plugin's respective share folder.

###Using API Keys
(tbd)

###Using the GEO Location API
(tbd)

###Common Code for Spice Endpoints (.pm's)
(tbd)

###Common JavaScript and Handlebars Templates
(tbd)

###Using Custom CSS
(tbd)
**\*\*Note**: Every Spice plugin result is wrapped in a `<div>` with an id of `spice_<spice_name>`.

For example the NPM plugin will have: `<div id="spice_npm">`. This allows any custom CSS you write to be scoped by addressing this id first for all your CSS rules. So, if the NPM plugin needed any CSS you could write it like so:

```css
#spice_npm pre {
    background: grey;
    ...
}
```

###Using images
(tbd)

------

##Common Pitfalls

###Defining Perl Variables and Functions
(tbd)

------

##StyleGuide
(overview - tbd)

###Formatting
(overview - tbd)

####Consistant Variable Names
ex. "api_return"

####Spice Header Format
`<search term>` (<Source>)

####No bolded text in Spice body
(tbd)

####No "undefined" values in Spice body (Spice result shouldn't say something is "not defined")
(tbd)

####Indent with spaces (not tabs)
(tbd)

------

###Naming Conventions
(tbd)

###Do's & Don'ts

####Proxying Images & Audio
/iu/
- Requires a standard image format extension!

####Add extra attribution
"More at" link should be enough

------

##FAQ

###I want to use 'X' API, but it doesn't have an endpoint for 'Y'. What should I do?
Email them! - If you explain what it's for, they might be willing to create and endpoint for you! If not, it's probably best to find an another API.

###Can I use an API that returns XML?
Sorry, but **no**. We currently don't support XML. We're considering it though...

###Can I use an API that returns HTML or a String? 
If the response is a single string, then yes - you can use `zci wrap_jsonp_callback`. You can read more about that [here](#). Or take a look at the [Automeme](https://github.com/duckduckgo/zeroclickinfo-spice/blob/spice2/lib/DDG/Spice/Automeme.pm#L8) plugin. If the response is more complicated, then sorry but **no**.

###Can I move the carousel detail area above the carousel?
Yup - Checkout the [**Khan Academy Spice**](https://github.com/duckduckgo/zeroclickinfo-spice/blob/spice2/share/spice/khan_academy/khan_academy.js) for an example.

All you need to do is set the `carousel_css_id` property in the `Spice.render()` call, and then use jQuery's `prependTo()` method, to move the detail area:

```javascript
Spice.render(){
    ...
    carousel_css_id: "my_unique_name",
    ...
}

$("#ddgc_detail").prependTo("#my_unique_name");
```

This snippet uses jQuery to grab the **#ddgc\_detail** `<div>` from the DOM, and then moves it right in front of the **#my_unique_name** `<div>`.  

**\*\*Note**: In order to move the carouse detail area, the `prependTo()` method must be used ***after*** the `Spice.render()` call because before that call, none of the `<div>`'s related to your Spice plugin exist in the DOM!

###Can I use the 'X', 'Y' or 'Z' JavaScript library?
Probably not. Maybe, if it is very small. But we prefer that no third party, extra libraries are used. ***Please*** ask us first before writing a plugin that is **dependent** on an extra library - we don't want you to waste your time and energy on something we can't accept!

###Can I use Coffeescript?
No.

###What about...
Nope. Just use JavaScript, please and thanks.

------

##DDG Methods (JavaScript)

###DDG.get_query()
(tbd)

###DDG.get_query_encoded()
(tbd)

###DDG.isRelevant()
(tbd)

###DDG.getRelevants()
(tbd)
(developers comparator function is required to assign a property of the candidate called comparable which is the string undergoing relevancy check in isRelevant)

###DDG.get_asset_path()
(tbd)

------

##Spice Helpers (Handlebars)

###{{\#concat}}
(tbd)

###{{\#condense}}
(tbd)

###{{\#loop}}
(tbd)

-------

##Spice Attributes (Perl)

###Spice to
(tbd)

###Spice from
(tbd)

###Spice wrap_jsonp_callback
If the API used for your plugin does not support JSONP (ie. it doesn't provide a URI parameter to indicate the callback function to be used on the API response), set `wrap_jsonp_callback` to true and the API response will automatically be wrapped in the appropriate function call for your plugin.

###Spice proxy_cache_valid 
(tbd)

###Spice is_unsafe
If your plugin has the potential to return unsafe results (eg. contains vulgar words, crude humour) the `is_unsafe` flag must be set to true. Any plugins that have `is_unsafe` set to true can only be seen when a user has safe-search turned off, or when they add the phrase `!safeoff` to their query (eg. "automeme !safeoff").

------

##Spice Helper Functions (Perl)

###share()
(tbd)
