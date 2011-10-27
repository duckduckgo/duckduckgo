/*
 *
 *  DuckDuckGo Translation JavaScript Library
 *
 */

if (typeof sprintf != 'function') {
	throw "ddg_translate.js: require a javascript sprintf implementation";
}

if (typeof Gettext != 'function' || typeof Gettext.strargs != 'function') {
	throw "ddg_translate.js: require Gettext.js of http://jsgettext.berlios.de/ to be loaded";
}

if (typeof ddg_translate != 'undefined') {
	throw "ddg_translate.js: ddg_translate.js already loaded";
}

var locale_data = {};

var ddg_translate = {

	curr: null,
	lang: null,
	dir: null,
	dry: 0,
	nowrite: 0,

	tds: {},
	
	l_dir: function(dir) {
		if (this.dir != null) {
			throw "ddg_translate.js: can't switch dir";
		}
		this.dir = dir;
	},

	l_dry: function(dry,nowrite) {
		this.dry = dry;
		this.nowrite = nowrite;
	},

	l_lang: function(lang) {
		if (this.lang != null) {
			throw "ddg_translate.js: can't switch language";
		}
		this.lang = lang;
	},

	// load: function(url, callback) {
		// var head = document.getElementsByTagName('head')[0];
		// var script = document.createElement('script');
		// script.type = 'text/javascript';
		// script.src = url;
		// script.onreadystatechange = callback;
		// script.onload = callback;
		// head.appendChild(script);
	// },
	
	ltd: function(textdomain) {
		if (!(textdomain in this.tds)) {
			// if (this.dir == null) {
				// throw "ddg_translate.js: please l_dir() before ltd()";
			// }
			// if (this.lang == null) {
				// throw "ddg_translate.js: please l_lang() before ltd()";
			// }
			// var loc_url = this.dir+'/'+this.lang+'/LC_MESSAGES/'+textdomain+'.json';
			this.tds[textdomain] = new Gettext({
				'domain': textdomain,
				'locale_data': locale_data
			});
		}
		this.curr = this.tds[textdomain];
		return textdomain;
	},
	
	wd: function(td,msgctxt,msgid,msgid_plural) {
		if (typeof console != 'object') {
			return;
		}
		if (typeof console.debug != 'function') {
			return;
		}
		if (td) { console.debug('# domain: '+td) }
		if (msgctxt) { console.debug('msgctxt "'+msgctxt+'"') }
		if (msgid) { console.debug('msgid "'+msgid+'"') }
		if (msgid_plural) { console.debug('msgid_plural "'+msgid_plural+'"') }
		console.debug('');
	},
	
	l: function() {
		var A = this.argarr(arguments);
		var id = A.shift();
		var gt;
		if (this.dry) {
			gt = id;
			if (!this.nowrite) {
				this.wd(null,null,id,null);
			}
		} else {
			gt = this.curr.gettext(id);
		}
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	ln: function() {
		var A = this.argarr(arguments);
		var id = A.shift();
		var idp = A.shift();
		var n = A.shift();
		var gt;
		if (this.dry) {
			if (n != 1) {
				gt = idp;
			} else {
				gt = id;
			}
			if (!this.nowrite) {
				this.wd(null,null,id,idp);
			}
		} else {
			gt = this.curr.ngettext(id,idp,n);
		}
		A.unshift(n);
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	lp: function() {
		var A = this.argarr(arguments);
		var ctxt = A.shift();
		var id = A.shift();
		var gt;
		if (this.dry) {
			gt = id;
			if (!this.nowrite) {
				this.wd(null,ctxt,id,null);
			}
		} else {
			gt = this.curr.pgettext(ctxt,id);
		}
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	lnp: function() {
		var A = this.argarr(arguments);
		var ctxt = A.shift();
		var id = A.shift();
		var idp = A.shift();
		var n = A.shift();
		var gt;
		if (this.dry) {
			if (n != 1) {
				gt = idp;
			} else {
				gt = id;
			}
			if (!this.nowrite) {
				this.wd(null,ctxt,id,idp);
			}
		} else {
			gt = this.curr.npgettext(ctxt,id,idp,n);
		}
		A.unshift(n);
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	ld: function() {
		var A = this.argarr(arguments);
		var td = A.shift();
		var id = A.shift();
		var gt;
		if (this.dry) {
			gt = id;
			if (!this.nowrite) {
				this.wd(td,null,id,null);
			}
		} else {
			gt = this.curr.dgettext(td,id);
		}
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	ldn: function() {
		var A = this.argarr(arguments);
		var td = A.shift();
		var id = A.shift();
		var idp = A.shift();
		var n = A.shift();
		var gt;
		if (this.dry) {
			if (n != 1) {
				gt = idp;
			} else {
				gt = id;
			}
			if (!this.nowrite) {
				this.wd(td,null,id,idp);
			}
		} else {
			gt = this.curr.dngettext(td,id,idp,n);
		}
		A.unshift(n);
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	ldp: function() {
		var A = this.argarr(arguments);
		var td = A.shift();
		var ctxt = A.shift();
		var id = A.shift();
		var gt;
		if (this.dry) {
			gt = id;
			if (!this.nowrite) {
				this.wd(td,ctxt,id,null);
			}
		} else {
			gt = this.curr.dpgettext(td,ctxt,id);
		}
		A.unshift(gt);
		return sprintf.apply(null,A);
	},
	
	ldnp: function(){
		var A = this.argarr(arguments);
		var td = A.shift();
		var ctxt = A.shift();
		var id = A.shift();
		var idp = A.shift();
		var n = A.shift();
		var gt;
		if (this.dry) {
			if (n != 1) {
				gt = idp;
			} else {
				gt = id;
			}
			if (!this.nowrite) {
				this.wd(td,ctxt,id,idp);
			}
		} else {
			gt = this.curr.dnpgettext(td,ctxt,id,idp,n);
		}
		A.unshift(n);
		A.unshift(gt);
		return sprintf.apply(null,A);
	},

	argarr: function(args) {
		var arr = new Array();
		for (var i=0, len=args.length; i<len; i++) {
			arr.push(args[i]);
		}
		return arr;
	}
	
};

function l_dry() { return ddg_translate.l_dry.apply(ddg_translate,arguments) }
function l_dir() { return ddg_translate.l_dir.apply(ddg_translate,arguments) }
function l_lang() { return ddg_translate.l_lang.apply(ddg_translate,arguments) }
function ltd() { return ddg_translate.ltd.apply(ddg_translate,arguments) }
function l() { return ddg_translate.l.apply(ddg_translate,arguments) }
function ln() { return ddg_translate.ln.apply(ddg_translate,arguments) }
function lp() { return ddg_translate.lp.apply(ddg_translate,arguments) }
function lnp() { return ddg_translate.lnp.apply(ddg_translate,arguments) }
function ld() { return ddg_translate.ld.apply(ddg_translate,arguments) }
function ldn() { return ddg_translate.ldn.apply(ddg_translate,arguments) }
function ldp() { return ddg_translate.ldp.apply(ddg_translate,arguments) }
function ldnp() { return ddg_translate.ldnp.apply(ddg_translate,arguments) }
