---
title: "Full-width M-F Embedded Google Calendars"
tags: ["WebDev"]
draft: false
---

Our university transitioned earlier this semester to a new CMS, and as part of that move, all of our content was basically pasted into a new template.
Mostly this works: [our center's page](https://www.fit.edu/math-advancement-center/) is quite simple, and the constraints of the new CMS will keep it that way...
However, the calendars we embed in the page didn't transfer well; Google calendar embedding is quite nice, but not super flexible!
In particular, the option one has in their own view to hide the weekends doesn't exist for embedded calendars.
This morning I decided to go ahead and fix this issue, and I'm recording it here so I don't have to look it up again.
Luckily, [someone already solved](https://productforums.google.com/forum/#!topic/calendar/w-YSMmONAQY) most of the problem; their solution required a few more tweaks (and I'm sure format changes on our side down the line will continue requiring maintenance...) but the result is below:

```
<div style="border: 1px solid black; width: 85%; height: 600px; overflow-y: scroll; overflow-x: scroll;">
<p style="width: 140%;">
<iframe
style="border: 0px #777;"
src="https://www.google.com/calendar/embed?showTitle=0&amp;showDate=0&amp;showPrint=0&amp;showTabs=0&amp;showCalendars=0&amp;showTz=0&amp;mode=WEEK&amp;height=600&amp;wkst=2&amp;bgcolor=%23FFFFFF&amp;src=rve7oijjit4pa8d3doa673nav0%40group.calendar.google.com&amp;color=%23875509&amp;ctz=America%2FNew_York"
width="100%" height="600px"
frameborder="0" scrolling="no">
</iframe>
</p>
</div>
```

Most of the settings one would normally apply to the actual `src` part of the iframe can be changed any way one would usually do; obviously, one should keep the height parameters synced up.
The key here is to adjust the width of the outer div and inner paragraph to hide exactly enough of the embedded calendar (at least, the part to the right of what we want to keep.)
