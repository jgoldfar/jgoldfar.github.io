---
title: "Quick SHA256 Generation using Julia"
date: 2018-10-11T13:15:29-04:00
draft: false
---

When generating reproducible software, you're often in the position of checking and generating SHA256 checksums from a given file.
Sure, there are command-line utilities that can do this on some platforms, but using a scripting language is more portable (thanks to the maintainers of that language, of course) and, if you've got a REPL open, nearly immediate: if your file path is present in `fname`, write

```
using SHA: sha256

open(fname) do file
    return bytes2hex(sha256(file))
end
```
