---
title: "Does DRY mean one thing?"
date: "2024-01-29T15:00:47-04:00"
tags: ["terms"]
draft: false
description: "thanks to undraw.co for the banner image"
banner: "img/banners/undraw_solution_mindset_re_57bf.png"
---

A few weeks ago, I posted [a poll on LinkedIn](https://www.linkedin.com/feed/update/urn:li:activity:7153370373462343680/) asking the question "What does DRY really mean?"

The options folks could choose from were

a) Don't Repeat Yourself
b) Do Repeat Yourself
c) Don't Remember Yesterday
d) Something else

Aside from the bit of fun that a poll on a social media network can be &mdash; they're engagement tools, not standardized tests after all &mdash; the reason I posed the question was to see if anyone would choose anything other than the oft-shared software development idiom in option a.

Folks tend to remember that one and think of it as a hard-and-fast requirement instead of a useful rule of thumb.
It is _usually_ helpful to reduce repetition, but there are times when exactly the opposite is true.

Sometimes the effort needed to encapsulate the functionality isn't worth the reduction in lines of code, even amortized over the many times the code will need to be maintained.
The juice may not be worth the squeeze, so to speak.

Sometimes you're testing a feature that can be better validated while existing in multiple forms, or you're experimenting with the behavior or performance characteristics of competing implementations. The difference could well be more than a "flag" or configuration that can easily be included without other impacts

In these and many other cases, DRY could mean "Do Repeat Yourself".
Or something else entirely.
Some may say that these are trivial examples, silly exceptions to what DRY "means".
I would remind those people that exceptional cases can be valuable.

If I'm missing something, or you have a question, or anything -- [I'd love to hear about it!](mailto:jgoldfar@gmail.com)
