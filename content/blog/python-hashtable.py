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
        """Get the index corresponding to the given `key`"""
        _hash = hash(key)
        return _hash % len(self.store)

    def put(self, key, value):
        """
        Store the `value` at the index given by `key`, growing the underlying storage if necessary.
        """
        number_store = len(self.store)
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

h = HashTable(1000)
h.put('yosemite', 'grandeur')
h.put('nevada', 'large')
h.put('florida', 'hot')

print(h.get('yosemite'))
print(h.get('florida'))

h.delete('florida')
print(h.get('florida'))
print(h.get('yosemite'))
