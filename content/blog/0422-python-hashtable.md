---
title: "Simple Python Hash Table"
date: "2021-04-22T09:00:47-04:00"
tags: ["python", "algorithms"]
draft: false
description: "thanks to undraw.io for the banner image"
banner: "img/banners/undraw_Source_code_re_wd9m.png"
---

The [hash table](https://en.wikipedia.org/wiki/Hash_table) or hash map is one of the fundamental data structures in computing.
It is an abstraction that allows a programming language user to think about
their problem at a level that is closer to the specifications developed for
business processes, instead of considering how the associated data is stored.
<!--more-->

Most languages provide a range of different levels of abstraction, including data structures much like the hash map.
Moreover, many software developers find they can be productive without introducing the label or formalism of a hash table -- myself included.
However, the pattern that the hash table represents is useful insofar as it generalizes to myriad data processing scenarios; knowing how objects like a hash table behave is a necessary but not sufficient condition for understanding modern software development.

Here's a dead simple hash table in Python:

```python
hashmap = {}
```

Yes of course, the Python `dict` is a hash table, but this is not a very interesting example.
Below, I will share a toy implementation of the hash table as a Python class so we can understand how the abstract definition can be implemented.
Rather than give a verbose description of its properties like the one we could read on Wikipedia (see the link above), I will document the code to describe the core behavior, and validate it through some trivial tests.
Later, I will remark on some properties we may want to improve or change the implementation to make it more reliable or useful.

Here's the implementation:
```python
class HashTable:
    """Create a hash map backed by a Python list"""
    store = []
    number_elements = 0

    def __init__(self, n: int = 1):
        """
        Create storage for a HashTable with `n` entries.
        """
        if n > 0:
            self.store = [None] * n
        else:
            self.store = [None]

    def getindex(self, key) -> int:
        """"""
        _hash = hash(key)
        return _hash % len(self.store)

    def put(self, key, value):
        """
        Store the `value` at the index given by `key`, growing the underlying storage if necessary.
        """
        number_store = len(store)
        if self.number_elements + 1 == number_store:
            self.store = self.store + ([None] * number_store)

        index = self.getindex(key)
        self.number_elements += 1
        self.store[index] = value

    def get(self, key):
        """
        Retrieve the value at the index given by `key`, or `None`.
        """
        index = self.getindex(key)
        return self.store[index]

    def delete(self, key):
        """
        Remove the data at the index `key`, if it exists.
        """
        index = self.getindex(key)
        if self.store[index] is not None:
            self.number_elements -= 1
            self.store[index] = None
```
The heavy lifting here is provided by the `hash` function, which is part of the Python standard library.
It converts its input into an integer in a deterministic way.
The implementation above will actually work with just about any type of key and value pairs you could think of, thanks to Python's design.

If you paste the class above into a Python file (or directly into the REPL!) and run it, you should be able to examine the interface with a few lines of code.
First, we initialize the `HashTable` with a backing array of 1000 elements - in Python, these can hold any kind of data.
Then, we insert some data and check that it can be retrieved:

```python
>>> h = HashTable(1000)
>>> h.put('yosemite', 'grandeur')
>>> h.put('nevada', 'large')
>>> h.put('florida', 'hot')

>>> print(h.get('yosemite'))
grandeur
>>> print(h.get('florida'))
```

We can delete elements:
```python
>>> h.delete('florida')
>>> print(h.get('yosemite'))
grandeur
>>> print(h.get('florida'))
None
```
That's it - the hash table here supports insertion of data, retrieval, and deletion.
Whatever issues you may see with this code (please - leave feedback!) there are a couple of critical ones that we have to address before using this for general purpose computation.

- The hash function may have _collisions_, which are instances where the different inputs (like two different strings) may produce the same result. The implementation above will happily overwrite data if the index of a newly added key/value pair overlaps with one that exists, among many other "footguns" that production-tested implementations of this pattern don't have. There are all kinds of fun approaches for tuning this pattern for different applications.

- Now that "production" has come up in the context of algorithms and software, the other glaring issue (to me) with the implementation in that context is a lack of proper tests or another means to validate its correctness, along with documentation on the code's use-cases and caveats. The level of polish that applies to professional work is out of scope for this page: as with most code you find online, this is not something to be used as a homework submission, much less anything actually important. If you would like to discuss an application to something important, [contact me!](/contact)
