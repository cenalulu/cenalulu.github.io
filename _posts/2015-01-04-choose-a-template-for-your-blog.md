---
layout: post
title:  "Jekyll&Github Pages博客模板挑选和配置"
date:   2014-12-29 01:53:43
categories: jekyll
---


> 当按照上一篇[jekyll入门教程]()步骤操作后，你就拥有了一个属于自己的免费Blog。但是界面非常的朴素甚至有时无法满足最基本的写作需求。因此本文将会简单的介绍jekyll模板的挑选和配置过程


# 模板挑选
---

jekyll的模板一般会有以下几个集中挑选的地方：
- [jekyllthemes.org](http://jekyllthemes.org/)
- [jekythemes.net](https://www.jekyllthemes.net/)
- [mademistakes](https://mademistakes.com/work/jekyll-themes/)
本博客使用的是[Skinny-Bones](http://mmistakes.github.io/skinny-bones-jekyll/)


~~~ bash
michelles-mbp:Blog michellezhou$ sudo gem install bundler
Fetching: bundler-1.7.11.gem (100%)
Successfully installed bundler-1.7.11
Parsing documentation for bundler-1.7.11
Installing ri documentation for bundler-1.7.11
1 gem installed
michelles-mbp:Blog michellezhou$ bun
bundle   bundler  bunzip2
michelles-mbp:Blog michellezhou$ bun
bundle   bundler  bunzip2
michelles-mbp:Blog michellezhou$ ls
cenalulu.github.io		skinny-bones-jekyll-master	skinny-bones-jekyll-master.zip
michelles-mbp:Blog michellezhou$ cd skinny-bones-jekyll-master
michelles-mbp:skinny-bones-jekyll-master michellezhou$ ls
Gemfile					_data					apple-touch-icon-precomposed.png	index.md
Gemfile.lock				_includes				atom.xml				js
Gruntfile.js				_layouts				css					package.json
LICENSE					_octopress.yml				favicon.ico
README.md				_sass					fonts
_config.yml				_templates				images
michelles-mbp:skinny-bones-jekyll-master michellezhou$ bundle install
Fetching gem metadata from https://rubygems.org/........
Using blankslate 2.1.2.4
Installing sass 3.4.7
Installing thor 0.19.1
Installing bourbon 4.0.2
Using hitimes 1.2.2
Using timers 4.0.1
Using celluloid 0.16.0
Using fast-stemmer 1.0.2
Installing classifier-reborn 2.0.2
Using coffee-script-source 1.8.0
Using execjs 2.2.2
Using coffee-script 2.3.0
Using colorator 0.1
Using ffi 1.9.6
Using jekyll-coffeescript 1.0.1
Using jekyll-gist 1.1.0
Using jekyll-paginate 1.1.0
Installing jekyll-sass-converter 1.2.1
Using rb-fsevent 0.9.4
Using rb-inotify 0.9.5
Installing listen 2.7.11
Installing jekyll-watch 1.1.2
Using kramdown 1.5.0
Using liquid 2.6.1
Installing mercenary 0.3.4
Using posix-spawn 0.3.9
Using yajl-ruby 1.1.0
Using pygments.rb 0.6.0
Installing redcarpet 3.2.0
Using safe_yaml 1.0.4
Using parslet 1.5.0
Using toml 0.1.2
Installing jekyll 2.4.0
Installing jekyll-sitemap 0.6.1
Installing neat 1.7.0
Installing octopress-hooks 2.2.1
Installing octopress-escape-code 1.0.2
Installing octopress-docs 0.0.9
Installing octopress-deploy 1.0.0
Installing titlecase 0.1.1
Installing octopress 3.0.0.rc.15
Using bundler 1.7.11
Your bundle is complete!
Use `bundle show [gemname]` to see where a bundled gem is installed.
~~~


# 运行提示错误
--- 

~~~ bash
michelles-mbp:skinny-bones-jekyll-master michellezhou$ jekyll server
WARN: Unresolved specs during Gem::Specification.reset:
      redcarpet (~> 3.1)
      jekyll-watch (~> 1.1)
      classifier-reborn (~> 2.0)
WARN: Clearing out unresolved specs.
Please report a bug if this causes problems.
/Library/Ruby/Gems/2.0.0/gems/jekyll-2.5.3/bin/jekyll:21:in `block in <top (required)>': cannot load such file -- jekyll/version (LoadError)
	from /Library/Ruby/Gems/2.0.0/gems/mercenary-0.3.5/lib/mercenary.rb:18:in `program'
	from /Library/Ruby/Gems/2.0.0/gems/jekyll-2.5.3/bin/jekyll:20:in `<top (required)>'
	from /usr/bin/jekyll:23:in `load'
	from /usr/bin/jekyll:23:in `<main>'
michelles-mbp:skinny-bones-jekyll-master michellezhou$ bundle exec jekyll server
Configuration file: /Users/michellezhou/Blog/skinny-bones-jekyll-master/_config.yml
            Source: /Users/michellezhou/Blog/skinny-bones-jekyll-master
       Destination: /Users/michellezhou/Blog/skinny-bones-jekyll-master/_site
      Generating...
                    done.
 Auto-regeneration: enabled for '/Users/michellezhou/Blog/skinny-bones-jekyll-master'
Configuration file: /Users/michellezhou/Blog/skinny-bones-jekyll-master/_config.yml
    Server address: http://0.0.0.0:4000/
  Server running... press ctrl-c to stop.
~~~

