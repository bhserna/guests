// Generated by CoffeeScript 1.9.3
(function() {
  var Teacup, doctypes, elements, fn1, fn2, fn3, fn4, i, j, l, len, len1, len2, len3, m, merge_elements, ref, ref1, ref2, ref3, tagName,
    slice = [].slice,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  doctypes = {
    'default': '<!DOCTYPE html>',
    '5': '<!DOCTYPE html>',
    'xml': '<?xml version="1.0" encoding="utf-8" ?>',
    'transitional': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">',
    'strict': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">',
    'frameset': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Frameset//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-frameset.dtd">',
    '1.1': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">',
    'basic': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML Basic 1.1//EN" "http://www.w3.org/TR/xhtml-basic/xhtml-basic11.dtd">',
    'mobile': '<!DOCTYPE html PUBLIC "-//WAPFORUM//DTD XHTML Mobile 1.2//EN" "http://www.openmobilealliance.org/tech/DTD/xhtml-mobile12.dtd">',
    'ce': '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "ce-html-1.0-transitional.dtd">'
  };

  elements = {
    regular: 'a abbr address article aside audio b bdi bdo blockquote body button canvas caption cite code colgroup datalist dd del details dfn div dl dt em fieldset figcaption figure footer form h1 h2 h3 h4 h5 h6 head header hgroup html i iframe ins kbd label legend li map mark menu meter nav noscript object ol optgroup option output p pre progress q rp rt ruby s samp section select small span strong sub summary sup table tbody td textarea tfoot th thead time title tr u ul video',
    raw: 'style',
    script: 'script',
    "void": 'area base br col command embed hr img input keygen link meta param source track wbr',
    obsolete: 'applet acronym bgsound dir frameset noframes isindex listing nextid noembed plaintext rb strike xmp big blink center font marquee multicol nobr spacer tt',
    obsolete_void: 'basefont frame'
  };

  merge_elements = function() {
    var a, args, element, i, j, len, len1, ref, result;
    args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
    result = [];
    for (i = 0, len = args.length; i < len; i++) {
      a = args[i];
      ref = elements[a].split(' ');
      for (j = 0, len1 = ref.length; j < len1; j++) {
        element = ref[j];
        if (indexOf.call(result, element) < 0) {
          result.push(element);
        }
      }
    }
    return result;
  };

  Teacup = (function() {
    function Teacup() {
      this.htmlOut = null;
    }

    Teacup.prototype.resetBuffer = function(html) {
      var previous;
      if (html == null) {
        html = null;
      }
      previous = this.htmlOut;
      this.htmlOut = html;
      return previous;
    };

    Teacup.prototype.render = function() {
      var args, previous, result, template;
      template = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      previous = this.resetBuffer('');
      try {
        template.apply(null, args);
      } finally {
        result = this.resetBuffer(previous);
      }
      return result;
    };

    Teacup.prototype.cede = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.render.apply(this, args);
    };

    Teacup.prototype.renderable = function(template) {
      var teacup;
      teacup = this;
      return function() {
        var args, result;
        args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
        if (teacup.htmlOut === null) {
          teacup.htmlOut = '';
          try {
            template.apply(this, args);
          } finally {
            result = teacup.resetBuffer();
          }
          return result;
        } else {
          return template.apply(this, args);
        }
      };
    };

    Teacup.prototype.renderAttr = function(name, value) {
      var k, v;
      if (value == null) {
        return " " + name;
      }
      if (value === false) {
        return '';
      }
      if (name === 'data' && typeof value === 'object') {
        return ((function() {
          var results;
          results = [];
          for (k in value) {
            v = value[k];
            results.push(this.renderAttr("data-" + k, v));
          }
          return results;
        }).call(this)).join('');
      }
      if (value === true) {
        value = name;
      }
      return " " + name + "=" + (this.quote(this.escape(value.toString())));
    };

    Teacup.prototype.attrOrder = ['id', 'class'];

    Teacup.prototype.renderAttrs = function(obj) {
      var i, len, name, ref, result, value;
      result = '';
      ref = this.attrOrder;
      for (i = 0, len = ref.length; i < len; i++) {
        name = ref[i];
        if (name in obj) {
          result += this.renderAttr(name, obj[name]);
        }
      }
      for (name in obj) {
        value = obj[name];
        if (indexOf.call(this.attrOrder, name) >= 0) {
          continue;
        }
        result += this.renderAttr(name, value);
      }
      return result;
    };

    Teacup.prototype.renderContents = function() {
      var contents, rest, result;
      contents = arguments[0], rest = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      if (contents == null) {

      } else if (typeof contents === 'function') {
        result = contents.apply(this, rest);
        if (typeof result === 'string') {
          return this.text(result);
        }
      } else {
        return this.text(contents);
      }
    };

    Teacup.prototype.isSelector = function(string) {
      var ref;
      return string.length > 1 && ((ref = string.charAt(0)) === '#' || ref === '.');
    };

    Teacup.prototype.parseSelector = function(selector) {
      var classes, i, id, klass, len, ref, ref1, token;
      id = null;
      classes = [];
      ref = selector.split('.');
      for (i = 0, len = ref.length; i < len; i++) {
        token = ref[i];
        token = token.trim();
        if (id) {
          classes.push(token);
        } else {
          ref1 = token.split('#'), klass = ref1[0], id = ref1[1];
          if (klass !== '') {
            classes.push(token);
          }
        }
      }
      return {
        id: id,
        classes: classes
      };
    };

    Teacup.prototype.normalizeArgs = function(args) {
      var arg, attrs, classes, contents, i, id, index, len, parsedSelector, selector;
      attrs = {};
      selector = null;
      contents = null;
      for (index = i = 0, len = args.length; i < len; index = ++i) {
        arg = args[index];
        if (arg != null) {
          switch (typeof arg) {
            case 'string':
              if (index === 0 && this.isSelector(arg)) {
                selector = arg;
                parsedSelector = this.parseSelector(arg);
              } else {
                contents = arg;
              }
              break;
            case 'function':
            case 'number':
            case 'boolean':
              contents = arg;
              break;
            case 'object':
              if (arg.constructor === Object) {
                attrs = arg;
              } else {
                contents = arg;
              }
              break;
            default:
              contents = arg;
          }
        }
      }
      if (parsedSelector != null) {
        id = parsedSelector.id, classes = parsedSelector.classes;
        if (id != null) {
          attrs.id = id;
        }
        if (classes != null ? classes.length : void 0) {
          if (attrs["class"]) {
            classes.push(attrs["class"]);
          }
          attrs["class"] = classes.join(' ');
        }
      }
      return {
        attrs: attrs,
        contents: contents,
        selector: selector
      };
    };

    Teacup.prototype.tag = function() {
      var args, attrs, contents, ref, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      ref = this.normalizeArgs(args), attrs = ref.attrs, contents = ref.contents;
      this.raw("<" + tagName + (this.renderAttrs(attrs)) + ">");
      this.renderContents(contents);
      return this.raw("</" + tagName + ">");
    };

    Teacup.prototype.rawTag = function() {
      var args, attrs, contents, ref, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      ref = this.normalizeArgs(args), attrs = ref.attrs, contents = ref.contents;
      this.raw("<" + tagName + (this.renderAttrs(attrs)) + ">");
      this.raw(contents);
      return this.raw("</" + tagName + ">");
    };

    Teacup.prototype.scriptTag = function() {
      var args, attrs, contents, ref, tagName;
      tagName = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      ref = this.normalizeArgs(args), attrs = ref.attrs, contents = ref.contents;
      this.raw("<" + tagName + (this.renderAttrs(attrs)) + ">");
      this.renderContents(contents);
      return this.raw("</" + tagName + ">");
    };

    Teacup.prototype.selfClosingTag = function() {
      var args, attrs, contents, ref, tag;
      tag = arguments[0], args = 2 <= arguments.length ? slice.call(arguments, 1) : [];
      ref = this.normalizeArgs(args), attrs = ref.attrs, contents = ref.contents;
      if (contents) {
        throw new Error("Teacup: <" + tag + "/> must not have content.  Attempted to nest " + contents);
      }
      return this.raw("<" + tag + (this.renderAttrs(attrs)) + " />");
    };

    Teacup.prototype.coffeescript = function(fn) {
      return this.raw("<script type=\"text/javascript\">(function() {\n  var __slice = [].slice,\n      __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; },\n      __hasProp = {}.hasOwnProperty,\n      __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };\n  (" + (this.escape(fn.toString())) + ")();\n})();</script>");
    };

    Teacup.prototype.comment = function(text) {
      return this.raw("<!--" + (this.escape(text)) + "-->");
    };

    Teacup.prototype.doctype = function(type) {
      if (type == null) {
        type = 5;
      }
      return this.raw(doctypes[type]);
    };

    Teacup.prototype.ie = function(condition, contents) {
      this.raw("<!--[if " + (this.escape(condition)) + "]>");
      this.renderContents(contents);
      return this.raw("<![endif]-->");
    };

    Teacup.prototype.text = function(s) {
      if (this.htmlOut == null) {
        throw new Error("Teacup: can't call a tag function outside a rendering context");
      }
      this.htmlOut += (s != null) && this.escape(s.toString()) || '';
      return null;
    };

    Teacup.prototype.raw = function(s) {
      if (s == null) {
        return;
      }
      this.htmlOut += s;
      return null;
    };

    Teacup.prototype.escape = function(text) {
      return text.toString().replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');
    };

    Teacup.prototype.quote = function(value) {
      return "\"" + value + "\"";
    };

    Teacup.prototype.use = function(plugin) {
      return plugin(this);
    };

    Teacup.prototype.tags = function() {
      var bound, boundMethodNames, fn1, i, len, method;
      bound = {};
      boundMethodNames = [].concat('cede coffeescript comment component doctype escape ie normalizeArgs raw render renderable script tag text use'.split(' '), merge_elements('regular', 'obsolete', 'raw', 'void', 'obsolete_void'));
      fn1 = (function(_this) {
        return function(method) {
          return bound[method] = function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            return _this[method].apply(_this, args);
          };
        };
      })(this);
      for (i = 0, len = boundMethodNames.length; i < len; i++) {
        method = boundMethodNames[i];
        fn1(method);
      }
      return bound;
    };

    Teacup.prototype.component = function(func) {
      return (function(_this) {
        return function() {
          var args, attrs, contents, ref, renderContents, selector;
          args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
          ref = _this.normalizeArgs(args), selector = ref.selector, attrs = ref.attrs, contents = ref.contents;
          renderContents = function() {
            var args;
            args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
            args.unshift(contents);
            return _this.renderContents.apply(_this, args);
          };
          return func.apply(_this, [selector, attrs, renderContents]);
        };
      })(this);
    };

    return Teacup;

  })();

  ref = merge_elements('regular', 'obsolete');
  fn1 = function(tagName) {
    return Teacup.prototype[tagName] = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.tag.apply(this, [tagName].concat(slice.call(args)));
    };
  };
  for (i = 0, len = ref.length; i < len; i++) {
    tagName = ref[i];
    fn1(tagName);
  }

  ref1 = merge_elements('raw');
  fn2 = function(tagName) {
    return Teacup.prototype[tagName] = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.rawTag.apply(this, [tagName].concat(slice.call(args)));
    };
  };
  for (j = 0, len1 = ref1.length; j < len1; j++) {
    tagName = ref1[j];
    fn2(tagName);
  }

  ref2 = merge_elements('script');
  fn3 = function(tagName) {
    return Teacup.prototype[tagName] = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.scriptTag.apply(this, [tagName].concat(slice.call(args)));
    };
  };
  for (l = 0, len2 = ref2.length; l < len2; l++) {
    tagName = ref2[l];
    fn3(tagName);
  }

  ref3 = merge_elements('void', 'obsolete_void');
  fn4 = function(tagName) {
    return Teacup.prototype[tagName] = function() {
      var args;
      args = 1 <= arguments.length ? slice.call(arguments, 0) : [];
      return this.selfClosingTag.apply(this, [tagName].concat(slice.call(args)));
    };
  };
  for (m = 0, len3 = ref3.length; m < len3; m++) {
    tagName = ref3[m];
    fn4(tagName);
  }

  if (typeof module !== "undefined" && module !== null ? module.exports : void 0) {
    module.exports = new Teacup().tags();
    module.exports.Teacup = Teacup;
  } else if (typeof define === 'function' && define.amd) {
    define('teacup', [], function() {
      return new Teacup().tags();
    });
  } else {
    window.teacup = new Teacup().tags();
    window.teacup.Teacup = Teacup;
  }

}).call(this);