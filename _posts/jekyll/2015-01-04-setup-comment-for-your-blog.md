---
layout: article
title:  "为Jekyll Blog添加文章评论的功能"
image:
    teaser: /teaser/disqus_teaser.png
categories: jekyll
---


> 当按照上一篇[jekyll入门教程]()步骤操作后，你就拥有了一个属于自己的免费Blog。本文将介绍如何为自己的静态博客添加一个博文评论的功能


# disqus注册
---

注册过程比较简单，甚至不需要验证邮箱（当然验证邮箱才能够使用所有完整功能，博主还是建议注册后立即去邮箱进行激活）。注册成功并登陆后就可以进入自己的后台配置界面啦。

![registration](/images/jekyll/comment-for-jekyll/1.png)


# 生成属于自己的comment js代码
---

注册并登陆后，通过右上角的`settings`按钮进入`admin`界面。然后在`settings`tag下就可以进行自己的comment专区的配置了。配置完成后点击`install`即可选择想要嵌入的目标博客类型。这里我们选择`universal code`即最基本的js代码
![config](/images/jekyll/comment-for-jekyll/3.png)
![config](/images/jekyll/comment-for-jekyll/2.png)


# 将js代码嵌入到Jekyll post模板中
---

通过修改`_layouts/post.html`将刚才admin界面中生成的comment js代码嵌入到模板的正文后

{% highlight html%}
{% raw %}
<div id="disqus_thread"> </div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'cenalulu'; // required: replace example with your forum shortname
        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="http://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
</div>
{% endraw %}
{% endhighlight %}


# 效果展示
---

效果当然就如你所见，本篇博文的下面就是成功配置了disqus的效果啦！
