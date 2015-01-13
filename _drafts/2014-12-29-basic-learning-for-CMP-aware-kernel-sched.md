---
layout: article
title:  "为CMP结构CPU优化的Linux内核调度系统"
date:   2014-12-29 01:53:43
categories: linux
---

>简介：
提示：为了避免翻译造成的概念混淆，文中的一些专有名词将会使用英文原文，如：Processor（处理器）, Core（核心）等


# 什么是Turbo Boost技术
---

Turbo Boost技术是Intel旗下CPU从Nehalem开始提出的一项优化技术。该技术能够在当一个Processor中有多个空闲core的时候，能够提升active core的运行频率（甚至超过标称频率），以达到提高执行效率的目的。（详见Reference：[Intel® Turbo Boost Technology in Intel® CoreTM Microarchitecture (Nehalem) Based Processors](http://files.shareholder.com/downloads/INTC/0x0x348508/C9259E98-BE06-42C8-A433-E28F64CB8EF2/TurboBoostWhitePaper.pdf))


# 什么是C-State
---

C-State代表了Core当前的活动状态。其中C0和C1为Intel所有处理器都支持的状态。C-State主要有以下值：

- C0: Core目前正在执行Instruction。Turbo Boost认为该状态下的core为active
- C1: Core目前没有在执行Instruction。Turbo Boost认为该状态下的core为active
- C3: Core的PLL已经关闭，并且cache已清空。Turbo Boost认为该状态下的core为inactive
- C6: Core的PLL已经关闭，并且cache已清空,且core状态被保存在last level cache中。Power Gate技术将这个状态下的core的电量消耗控制在0。Turbo Boost认为该状态下的core为inactive













