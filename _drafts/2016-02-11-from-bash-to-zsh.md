---
layout: article
title: "From Bash to Zsh"
modified:
categories: 
#excerpt:
#tags: []
#image:
#    feature: /teaser/xxx
#    teaser: /teaser/xxx
#    thumb:
date: 2016-02-11T11:07:24+00:00
---



> 文章欢迎转载，但转载时请保留本段文字，并置于文章的顶部
> 作者：卢钧轶(cenalulu)
> 本文原文地址：<http://cenalulu.github.io{{ page.url }}>

{% highlight python %}
{% raw %}

## Different history format


*必须要SAVEHIST才会有history file
## history
HISTSIZE=10000
SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt hist_ignore_dups # ignore duplication command history list
setopt append_history # append rather then overwrite
setopt inc_append_history # add history immediately after typing a command
setopt SHARE_HISTORY


## 特性，支持各个shell之间共享history file


## Change default
sudo chsh -s /bin/zsh 



## Very slow
Update date to later than 5.0.2 and use this trick to profile:
https://kev.inburke.com/kevin/profiling-zsh-startup-time/


```
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    2        8666.70  4333.35   55.84%   8666.70  4333.35   55.84%  compdump
 2) 1530        1626.80     1.06   10.48%   1626.80     1.06   10.48%  compdef
 3)    2       13133.35  6566.68   84.62%   1457.35   728.67    9.39%  compinit
 4)    4        1407.90   351.97    9.07%   1407.90   351.97    9.07%
compaudit
 5)    2        6907.79  3453.89   44.51%    796.31   398.16    5.13%  pmodload
 6)    2         479.80   239.90    3.09%    479.80   239.90    3.09%
promptinit
 7)    1         476.21   476.21    3.07%    476.21   476.21    3.07%
VCS_INFO_check_com
 8)    1         474.74   474.74    3.06%    474.74   474.74    3.06%
vcs_info_setsys
 9)    2          66.15    33.08    0.43%     66.15    33.08    0.43%
bashcompinit
10)    2          30.29    15.15    0.20%     30.29    15.15    0.20%
editor-info
11)    1         487.25   487.25    3.14%     11.04    11.04    0.07%
VCS_INFO_detect_git
12)   38          35.14     0.92    0.23%      9.75     0.26    0.06%  complete
13)    3           4.20     1.40    0.03%      4.20     1.40    0.03%  (anon)
14)    7           4.09     0.58    0.03%      4.09     0.58    0.03%
add-zsh-hook
15)    2         966.04   483.02    6.22%      1.79     0.90    0.01%  vcs_info
16)    6           1.13     0.19    0.01%      1.13     0.19    0.01%
url-quote-magic
17)    1           9.29     9.29    0.06%      0.95     0.95    0.01%
set_prompt
18)    2           4.84     2.42    0.03%      0.93     0.47    0.01%
prompt_agnoster_setup
19)    2           0.74     0.37    0.00%      0.74     0.37    0.00%
VCS_INFO_quilt
20)    1           0.69     0.69    0.00%      0.69     0.69    0.00%
is-at-least
21)    2           0.43     0.22    0.00%      0.43     0.22    0.00%
VCS_INFO_hook
22)    2           0.74     0.37    0.00%      0.38     0.19    0.00%
VCS_INFO_set
23)    2           0.27     0.14    0.00%      0.27     0.14    0.00%
VCS_INFO_maxexports
24)    2           0.26     0.13    0.00%      0.26     0.13    0.00%
VCS_INFO_nvcsformats
25)    1           9.49     9.49    0.06%      0.20     0.20    0.00%  prompt
26)    1           0.18     0.18    0.00%      0.18     0.18    0.00%
VCS_INFO_get_cmd
27)    1          15.82    15.82    0.10%      0.16     0.16    0.00%
zle-line-finish
28)    1          14.78    14.78    0.10%      0.14     0.14    0.00%
zle-line-init
29)    1         966.13   966.13    6.23%      0.09     0.09    0.00%
prompt_agnoster_precmd
30)    1           0.06     0.06    0.00%      0.06     0.06    0.00%
is-callable

-----------------------------------------------------------------------------------

       1/2      5621.24  5621.24   36.22%    625.47   625.47
pmodload [5]
 3)    2       13133.35  6566.68   84.62%   1457.35   728.67    9.39%  compinit
       2/4      1407.90   703.95    9.07%      1.00     0.50
compaudit [4]
    1492/1530   1601.41     1.07   10.32%   1601.41     1.07
compdef [2]
       2/2      8666.70  4333.35   55.84%   8666.70  4333.35
compdump [1]

-----------------------------------------------------------------------------------

       2/2      8666.70  4333.35   55.84%   8666.70  4333.35
compinit [3]
 1)    2        8666.70  4333.35   55.84%   8666.70  4333.35   55.84%  compdump

-----------------------------------------------------------------------------------

       1/2         1.13     1.13    0.01%      0.92     0.92
pmodload [5]
 5)    2        6907.79  3453.89   44.51%    796.31   398.16    5.13%  pmodload
       1/1         0.06     0.06    0.00%      0.06     0.06
is-callable [30]
       2/3         0.88     0.44    0.01%      0.88     0.44             (anon)
[13]
       1/2         1.13     1.13    0.01%      0.92     0.92
pmodload [5]
       1/1         9.49     9.49    0.06%      0.20     0.20             prompt
[25]
       1/2       479.80   479.80    3.09%      0.72     0.72
promptinit [6]
       1/2      5621.24  5621.24   36.22%    625.47   625.47
compinit [3]
```


rm ~/.zcompdump && ln -s /data/users/junyilu/local_config/zcompdump ~/.zcompdump

## Profile code
```
zmodload zsh/zprof
PROFILE_STARTUP=true
if [[ "$PROFILE_STARTUP" == true ]]; then
    # http://zsh.sourceforge.net/Doc/Release/Prompt-Expansion.html
    PS4=$'%D{%M%S%.} %N:%i> '
    exec 3>&2 2>/tmp/startlog.$$
    setopt xtrace prompt_subst
fi


# Entirety of my startup file... then
if [[ "$PROFILE_STARTUP" == true ]]; then
    unsetopt xtrace
    exec 2>&3 3>&-
fi
```


Or `zprof -c`



## Perl-like Regular Expression

当然Bash
3.0以后也有正则Condition支持，但是语法相对就比较生涩。对于习惯Perl语法的人来说zsh的正则支持是最贴近使用习惯的
 ```
#! /bin/zsh

url='http://www.google.com/main'
if [[ $url =~ '^http:\/\/([^/]+)*/(.*)+$' ]]
then
    echo $match[1]
fi
```

result:
```
www.google.com
```


## 计算支持

```
echo $(( [#10] 0xFF ))
255
```



## Reference

1. https://grml.org/zsh/zsh-lovers.html
{% endraw %}
{% endhighlight %}
