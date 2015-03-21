---
layout: article
title:  "10分钟搭建一个基于github和jekyll的免费博客"
date:   2014-12-28 01:53:43
categories: jekyll
---

>简介：本文主要介绍如何使用jekyll搭配markdown语法，在github上搭建一个免费的博客


# 方案的优势
- github基于github-pages的博客方案完全免费，且有稳定性保障
- 所有博文可以通过github做版本管理
- 使用markdown语法写博客,可以专注于内容无需过度关心页面样式
- markdown语法目前有非常多的博客托管网站支持，方便日后迁移
- jekyll支持markdown to html的转换，以及YAML支持。方便跟多的样式的修改


# 准备知识&名词解释
---

- Markdown: 一种语法标准，用于将一些简单的格式转换成html的语法
- Markdown Engine: 用于将Makrdown语法的文本转换成html文件或者输出
    - Github支持的Markdown engine: kramdown(default), redcarpet
    - jekyll支持的Markdown engine：kramdown(default), redcarpet
- Markdown for Vim: 

# 步骤一：申请一个github-pages blog
---

具体的步骤在github的帮助页面都有step-by-step的介绍，这里就照搬几张操作截图
按照以下步骤操作以后，现在你就已经拥有一个通过github服务的blog啦！

- 域名是：<username>.github.io
- 博文存放在repository：<username>/<username>.github.io

当然这也就意味着如果你手工创建一个同样规则的repository的话，github同样也会自动识别为是一个博客系统文件的项目


# 步骤二：在本地搭建一个jekyll环境
---

如果本机已经有现成ruby基础环境
{% highlight bash %}
gem install jekyll
{% endhighlight %}

如果是中国大陆用户那么默认的gem源进行安装会有一定困难。这里推荐使用[taobao的ruby源](https://ruby.taobao.org/)。简单的使用以下命令就可以将淘宝repo作为默认repo。
{% highlight bash %}
gem sources --remove https://rubygems.org/
gem sources -a https://ruby.taobao.org/
gem sources -l
{% endhighlight %}

安装完jekyll以后就可以创建一个本地的博客书写目录，进入自己喜欢的路径执行以下命令。随后jekyll就会自动生成一些博客的基础文件和目录，并且包含一篇现成的博文介绍jekyll

{% highlight bash %}
{% raw %}
mkdir -p ~/Blog && cd ~/Blog
jekyll new .
{% endraw %}
{% endhighlight %}


创建完本地博客目录后，可以启动jekyll的管理进程（作用相当于apache），然后就可以通过浏览器看到效果啦！

{% highlight bash %}
{% raw %}
shell> cd ~/Blog
shell> jekyll serve
Configuration file: /Users/michellezhou/Blog/cenalulu.github.io/_config.yml
Source: /Users/michellezhou/Blog/cenalulu.github.io
Destination: /Users/michellezhou/Blog/cenalulu.github.io/_site
Generating...
done.
Auto-regeneration: enabled for '/Users/michellezhou/Blog/cenalulu.github.io'
Configuration file: /Users/michellezhou/Blog/cenalulu.github.io/_config.yml
Server address: http://127.0.0.1:4000/
Server running... press ctrl-c to stop.

{% endraw %}
{% endhighlight %}


通过浏览器访问 http://localhost:4000/ 就可以看到如下效果:
![pic]({{ site.url }}/images/jekyll/how_to_jekyll/1.png)


# 步骤三：进行一些简单的个性化配置
---

由于jekyll自动生成博客框架中有较多的默认值，并且比针对github有特殊处理所以我们在把自己的第一版博客发布到github之前需要做一些个性化配置（博客名，个人信息等）。当然，如果你觉得留着这些默认值也可直接跳过这一段，直接进行发布:)
个性化配置主要在_config.yml中进行

{% highlight yaml %}
{% raw %}
title: <title>
email: <email>
description: > # <description>
twitter_username: <twitter_username>
github_username:  <github_username>
kramdown:
  input: GFM
{% endraw %}
{% endhighlight %}


在post-list页面（也即index页面)增加excerpt（即文章简介功能）。将Blog根目录下的index.html中`site.pages`这一行下增加一行 {% raw %} `{{ post.excerpt }}` {% endraw %}


# Tips
---

- kramdown的语法，以及对Markdown的渲染和最基础的Markdown之间有一定差别，建议查阅[kramdown官方文档](http://kramdown.gettalong.org/quickref.html)
- 如果是Vim党，那么可以使用[vim-markdown](https://github.com/gabrielelana/vim-markdown)这个插件编辑Markdown文件
- jekyll的html渲染时还使用了基于liquid的模板语法，如果希望在文中输出例如 {% raw %} `{{ word_to_escape }}` {% endraw %} 这样的标签可以参考[stackoverflow上的回答](http://stackoverflow.com/questions/3426182/how-to-escape-liquid-template-tags)


## reference
---

1. <https://help.github.com/articles/using-jekyll-with-pages/>
2. [build blog with jekyll and github pages](http://www.smashingmagazine.com/2014/08/01/build-blog-jekyll-github-pages/)
3. [manage post ecerpt](http://melandri.net/2013/11/24/manage-posts-excerpt-in-jekyll/)


