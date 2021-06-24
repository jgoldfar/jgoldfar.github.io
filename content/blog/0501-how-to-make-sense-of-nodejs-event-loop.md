---
title: "How To Make Sense of the NodeJS Event Loop"
date: "2021-06-12T09:00:47-04:00"
tags: ["nodejs", "web-services"]
draft: false
description: "thanks to undraw for the banner image - https://undraw.co/illustrations"
banner: "img/banners/undraw_design_components_9vy6.png"
---

When you're writing JavaScript code for NodeJS, you don't often need to think about how your code will be executed.
You may be thinking about the models you are working with, how data moves through your application, or what guarantees you need to be able to provide to meet your acceptance criteria - or you may have another framework in mind.

One of the great things about JavaScript on the Node runtime as a developer is that you get to write code at a high level and have your code execute efficiently on hardware.
When you need to have a better understanding of what happens after you kick off that asynchronous request, I recommend [this article](https://www.timcosta.io/the-node-js-event-loop/) by Tim Costa to get you started.

You can read a lot out there on [Node.JS](https://nodejs.org/en/), its design goals, and how they enable high performance applications for some use-cases.
I recommend starting with the fundamentals while writing code in a trial-outcome-hypothesis loop.
If you have a problem and want to experiment with Node, [I would love to hear about it](mailto:jgoldfar@gmail.com)!
