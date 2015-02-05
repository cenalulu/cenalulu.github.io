---
layout: article
title:  "为Bash和VIM配置一个美观奢华的状态提示栏"
categories: linux
toc: true
ads: true
image:
    teaser: /teaser/powerline.png
---


> 本文将详细介绍在Mac环境下安装powerline的方式


## 什么是powerline

如果你不是通过搜索引擎搜到这篇文章的话，也许你还没有听说过[powerline](https://github.com/powerline/powerline)。而你又恰巧是个*UNIX党，或者VIM党的话，那么强烈建议你了解并使用powerline。powerline是一个stateless status line，即一个全局状态/提示栏。如果你成功为你的`bash`,`Terminal`,`iTerm2`,`VIM`配置上powerline的话，那么效果将会是这样的：

Bash的提示符将会是这样的：
![Bash]({{ site.url }}/images/linux/powerline/bash.png)

VIM的状态栏将会是这样的：
![vim]({{ site.url }}/images/linux/powerline/vim.png)

VIM的整体效果图：
![whole]({{ site.url }}/images/linux/powerline/whole.png)

相信看了以上几个截图后，powerline的功能也就不言而喻了。他提供了各个app各个环境下的状态提示，极大的提高了工作效率



## 开始Mac上安装powerline

首先我们需要下载安装powerline。在正式安装之前先啰嗦几句powerline的代码结构，github上的powerline项目下涵盖了用于适配各种APP(bash，vim等)的代码。因此，你完全可以在Mac任何一个地方下载该代码包，然后将不同的APP配置使用这个路径，以Plugin形式加载。为了方便读者选择性安装，本文对于不同的程序将分开给出安装路径和配置。

先确定本机环境有一套版本大于等于`2.7`的`Python`的环境。如果没有合适环境的话，可以通过homebrew安装，这里不多做赘述。
{% highlight bash %}
{% raw %}
shell> python -v
Python 2.7.9
{% endraw %}
{% endhighlight %}

然后通过`pip`安装powerline：
{% highlight bash %}
{% raw %}
shell> pip install powerline-status
{% endraw %}
{% endhighlight %}

安装完成后通过`pip show powerline-status`查看powerline所处的具体路径。*注意：这个路径很重要，会用在之后的配置环节*
{% highlight bash %}
{% raw %}
shell> pip show powerline-status
Name: powerline-status
Version: 2.0
Location: /Library/Python/2.7/site-packages
Requires:
{% endraw %}
{% endhighlight %}


## 配置Bash使用powerline

配置方法很简单，只需要在Bash配置文件(例如：`/etc/bashrc`，`~/.bashrc`，`~/.bash_profile`)中增加一行调用安装路径下的`bindings/bash/powerline.sh`即可。这样每次调用生成新的Bash窗口时，都会自动执行`powerline.sh`文件中的内容。下面以`~/.bash_profile`为例：

{% highlight bash %}
{% raw %}
shell> echo << EOF >> ~/.bash_profile 
. /Library/Python/2.7/site-packages/powerline/bindings/bash/powerline.sh
EOF
shell> . /Library/Python/2.7/site-packages/powerline/bindings/bash/powerline.sh
{% endraw %}
{% endhighlight %}

*注意：根据python安装方式的不同，你的powerline所在路径也可能不同。*如果你是通过python官网或者apple store通过安装工具安装的python，那么你的powerline安装路径就是`/Library/Python/2.7/site-packages/powerline/`。如果你是通过`brew install python`的话，那么你的powerline路径可能会有不同。请根据实际情况修改上面的命令。



## Teriminal字体配置

执行完上面两步后，不出意外powerline就已经开始工作了。但是你会发现Bash提示符会和下图一样是一些非常恶心的符号。
![mojibake]({{ site.url }}/images/linux/powerline/moji.png)
出现这样情况的原因是powerline为了美观自己造了一些符号，而这些符号不在Unicode字库内（如果你不知道Unicode字库是什么的话可以看下博主[以前的相关介绍]({{site.url}}/linux/character-encoding/)）。所以想要powerline正常显示的话，需要安装特殊处理过的字体。好在有一位热心人的帮助，他把大部分的程序猿常用的等宽字体都打上了powerline patch使得我们的这部配置将异常简单。首先我们从github上下载并安装字体：

{% highlight bash %}
{% raw %}
shell> git clone https://github.com/powerline/fonts.git
shell> cd fonts
shell> ./install.sh
{% endraw %}
{% endhighlight %}

安装完成后我们就可以在`iTerm2`或者`Terminal`的字体选项里看到并选择多个`xxx for powerline`的字体了。*注意：对于`ASCII fonts`和`non-ASCII fonts`都需要选择`for powerline`的字体。如下图：
![fonts]({{ site.url }}/images/linux/powerline/fonts.png)



## VIM相关配置

这部分我们将介绍如何为VIM配置powerline。首先你需要确保你的vim编译时开启了python支持。如果通过`python --version|grep +python`没有结果的话，那么你需要通过`brew install vim --with-python --with-ruby --with-perl`重新编译安装vim，或者使用`brew install macvim --env-std --override-system-vim`安装macvim。

然后，你只需要在`~/.vimrc`中加上以下部分，VIM就能够正常加载powerline功能了：
*注意：其中`set rtp+=/Library/Python/2.7/site-packages/powerline/bindings/vim`和上文一样需要按照自己的实际情况调整。*

{% highlight vim %}
{% raw %}
set rtp+=/Library/Python/2.7/site-packages/powerline/bindings/vim

" These lines setup the environment to show graphics and colors correctly.
set nocompatible
set t_Co=256
 
let g:minBufExplForceSyntaxEnable = 1
python from powerline.vim import setup as powerline_setup
python powerline_setup()
python del powerline_setup
 
if ! has('gui_running')
   set ttimeoutlen=10
   augroup FastEscape
      autocmd!
      au InsertEnter * set timeoutlen=0
      au InsertLeave * set timeoutlen=1000
   augroup END
endif
 
set laststatus=2 " Always display the statusline in all windows
set guifont=Inconsolata\ for\ Powerline:h14
set noshowmode " Hide the default mode text (e.g. -- INSERT -- below the statusline)
{% endraw %}
{% endhighlight %}




#### Reference:
[powerline](https://github.com/powerline/powerline)
[powerline installation](https://powerline.readthedocs.org/en/latest/installation.html)
[setup vim powerline](https://coderwall.com/p/yiot4q/setup-vim-powerline-and-iterm2-on-mac-os-x)
[getting spiffy with powerline](http://computers.tutsplus.com/tutorials/getting-spiffy-with-powerline--cms-20740)
