---
title: "Continuous Integration Ad Nauseam?"
tags: ["CI"]
draft: true
---

Anyone who's tried to look back on a document from years ago probably knows how difficult it can be for anything more than the simplest files.
There are [good](https://en.wikipedia.org/wiki/Software_rot) [reasons](https://en.wikipedia.org/wiki/Entropy) why, over a long enough time scale, such problems are likely unavoidable (though that [doesn't](https://en.wikipedia.org/wiki/Voyager_Golden_Record) [stop](https://en.wikipedia.org/wiki/Long_Now_Foundation) us from [trying](http://www.slate.com/articles/health_and_science/green_room/2009/11/atomic_priesthoods_thorn_landscapes_and_munchian_pictograms.html), with completely unknown results.)

A backup is no good if you can't open it, and even if it opens or runs on your machine, how do you know the recipient of your work has a chance of having the same luck.
Not to mention the possibility that an inevitable computer crash or upgrade could have disastrous consequences for the future of your work.
Speaking for myself, as the recipient of multiple literal crashes (with cars, on my bike) and regular deluges during my commute, it's a wonder my 2012 MacBook still runs.
Indeed, some days it refuses to.

I'm going to give my solution for the short-term problem of being able to reliably open and run _your own_ work for about as long as you care to keep it around.
Long story short, I've developed some techniques for running all kinds of codes on multiple CI services, as well as my own package for checking that my "mono-repo" correctly integrates changes and can continue to compile, well, everything I've worked on dating back to 2005 or so (I am lucky to be an early TeX and OSS adopter for my own work, so I'm not stuck with many opaque binary files; that would be a significant limitation...)

The base repository wasn't designed to be open source from the outset, so it contains possibly sensitive work information (ah, isn't it nice to know that nothing you commit, even by accident, can be lost...)[1]
While I can't share that, I can show how my CI system works.




## Footnotes

[1] While I know it's well possible to scrub data from commits, I don't think it's worth the effort.