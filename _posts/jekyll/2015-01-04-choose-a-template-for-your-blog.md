---
layout: article
title:  "Jekyll&Github Pages博客模板挑选和配置"
date:   2014-12-29 01:53:43
toc: true
disqus: true
categories: jekyll
---


> 当按照上一篇[jekyll入门教程]()步骤操作后，你就拥有了一个属于自己的免费Blog。但是界面非常的朴素甚至有时无法满足最基本的写作需求。因此本文将会简单的介绍jekyll模板的挑选和配置过程


## 模板挑选

jekyll的模板一般会有以下几个集中挑选的地方：
- [jekyllthemes.org](http://jekyllthemes.org/)
- [jekythemes.net](https://www.jekyllthemes.net/)
- [mademistakes](https://mademistakes.com/work/jekyll-themes/) （本博客就是从这位大神的多个jekyll模板中挑选的）
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


## 运行提示错误

~~~ bash
michelles-mbp:skinny-bones-jekyll-master michellezhou$ jekyll server
WARN: Unresolved specs during Gem::Specification.reset:
      redcarpet (~> 3.1)
      jekyll-watch (~> 1.1)
      classifier-reborn (~> 2.0)
WARN: Clearing out unresolved specs.
Please report a bug if this causes problems.
/Library/Ruby/Gems/2.0.0/gems/jekyll-2.5.3/bin/jekyll:21:in block in <top (required)>': cannot load such file -- jekyll/version (LoadError)
	from /Library/Ruby/Gems/2.0.0/gems/mercenary-0.3.5/lib/mercenary.rb:18:in program'
	from /Library/Ruby/Gems/2.0.0/gems/jekyll-2.5.3/bin/jekyll:20:in <top (required)>'
	from /usr/bin/jekyll:23:in load'
	from /usr/bin/jekyll:23:in <main>'
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


## 模板基本配置

然后就是模板的配置，配置过程相对简单。比较费时的地方就是为自己的博客挑选头像和文章简介图片（teaser）。博主这里头像用PhotoEditor将照片调整到模板推荐的`120x120`大小，文章简介直接在google上搜`400x250`然后将图片放置到根目录下的`/images/`并进行配置即可

~~~ 
\# Site wide configuration

title: "cenalulu's Tech Blog"
description: "Collection of everythings I want to record down especially for tech"
logo: logo.jpg # 120x120 px default image used for Twitter summary card
teaser: teaser.jpg# 400x250 px default teaser image used in image archive grid
locale:
url: 

\# Jekyll configuration

sass:
    sass_dir: _sass
    style: compressed
permalink: /:categories/:title/
markdown: kramdown
highlighter: pygments
gems:
  - jekyll-sitemap


\# Site owner
owner: 
  name: cenalulu（卢钧轶）
  email: cenalulu@gmail.com
  twitter: cenalulu
  google:
    ad-client:
    ad-slot:
  bio:
  avatar: bio-photo.jpg # 160x160 px image for author byline
disqus-shortname: cenalulu

~~~

下图是基本配置后的博客效果


## 模板页头导航配置

只进行基本配置博客会显得比较单调。这部分介绍下页头导航栏的配置。具体配置在`_data/navigation.yml`中进行。拿本博客的页头导航举例，具体语法如下：

~~~ html
- title: Home
  url: /
  excerpt: 
  image: 

- title: MySQL
  url: /mysql/

- title: Linux
  url: /linux/

- title: Python
  url: /python/

- title: Jekyll
  url: /jekyll/

~~~

当然光进行这样的配置，仅仅是做到了显示页头导航的作用。如果要使得点击每个页头标签能够跳转到对应分类的博文列表的话，还需要在根目录下建立和category名对应的文件夹，并在文件夹中放置一个`index.md`的文件用作于分类导航页的渲染。还是拿本博客举例，可以看到页头上方有：mysql, python, linux, jekyll 四个分类。那么我们就需要在blog的根目录下手工创建四个文件夹`mysql`,`python`,`linux`,`jekyll`，并且在这四个文件夹中都创建一个`index.md`。这个文件的内容决定了每个分类的首页如何展示。当然最简单快速的方法是把根目录下的`index.md`copy过来稍作修改。同时把permlink配置删掉，再把 `site.posts` 改成`site.categories.mysql`这里`mysql`替换为对应分类的名字即可。修改后的结果如下图。

~~~







