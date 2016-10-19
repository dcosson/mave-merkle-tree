# MAVEMerkleTree

Objective-C implementation of a Merkle tree for iOS, using json to serialize values.

A Merkle tree is a useful data structure for efficiently diffing and replicating one data source
from another, which differes by an arbitrary amount. The key property is that the changes are
unknown, for example the source data is controlled by a process outside of your control and all you
can do is check the current state periodically. (If you control writing the changes or otherwise
have access to a change log, the more obvious solution is to replicate data by applying the change
log).

As an example, using a merkle tree can be useful for syncing an iOS Contact book to a remote server,
since the user's contacts may have changed by an arbitrary amount since the last time your app ran.

## Usage

### Creating a merkle tree from local data

Create a new merkle tree object (the following examples will all work in Objective-C or Swift):

```
let tree = MAVEMerkleTree(height: 10, arrayData: data, dataKeyRange: MAVEMakeRange64(0, .max), hashValueNumBytes: 5)
```

Height is the height of the resulting (binary) Merkle tree, and `arrayData` is an array of objects
that implement the `MAVEMerkleTreeDataItem` protocol.

To implement the `MAVEMerkleTreeDataItem` protocol, you need a `merkleTreeDataKey` which is a uniformly-distributed UInt64 between the
range given to `dataKeyRange` (in this case, the full 64-bits of UInt64 objects). If you have, say,
an incrementing integer primary key for your data, you'll want to hash it and take the first 8 bytes
as a UInt64 so that the keys are uniformly distributed.

You also need `merkleTreeSerializableData` which is some JSON-serializable[1] data representing this
object.

You can serialize a json-representation of your tree with the following command, for example to
write to disk or send up to your server so that you can check against it again later.

```
let jsonRepr = tree.serializable()
```

### Loading a serialized tree

Load a serialized merkle tree with:

```
let otherTree = MAVEMerkleTree.init(jsonObject: otherJsonRepr)
```

This tree doesn't have the actual data values, just the hash tree that you can compare to see which
buckets have changed between `otherTree` and the current data represented by `tree`.

### Comparing Merkle trees

Compare trees with:

To generate the Merkle tree, we split the input `arrayData` into `2 ^ (height - 1)` buckets and within
each bucket json-serialize and hash the array. Then, each two buckets are hashed recursively up to
the tree, ending with a single hash value that represents the tree. If data in a single bucket then
changes, the root hash will now be different but all of the leaf nodes except the one with changed
data will be the same as before, so we can easily traverse the old and new trees and find exactly
which bucket(s) have changed.

```
let changeset = tree.changesetForOtherTree(toMatchSelf: otherTree)
```

Or, if this is the initial sync, you can compare against an "empty" otherTree with:

```
let changesets = tree.changesetForEmptyToMatchSelf()
```

The return value is a list of changesets, each of which is a tuple (exprssed as an NSArray) of 4 values: `[nodeNumber, [rangeLow, rangeHigh], hashValue, data]`. 

`nodeNumber` is the leaf node number of the this bucket in the merkle tree, for instance if the tree
had height 4 this is an integer from 0 to 7 representing leaf nodes from left to right. The range
low and high tuple is the subset of the key space (inclusive) that this bucket maps to. The
`hashValue` is the hashed value of this data bucket. The `data` is the subset of your data objects
implementing the `MAVEMerkleTreeDataItem` protocol that mapped to this bucket.

Only changesets of buckets that don't match have changed. From here, it's up to you to synchronize
these objects in the changesets. Check the same buckets in the remote source, deleting any objects
which no longer exist, creating any new objects, and updating any changed objects.


### JSON Serialization Gotchas

When creating the json-serializable data objects you pass into MAVEMerkleTree, it's important to
realize that "objects" (or dictionaries) in JSON are unordered. That means if you have an object
with more than one key in it, it may not hash to the same JSON string even if nothing has changed.
So, you'll want to convert data hashes to tuple arrays (just arrays of arrays in JSON).

For example this:

```
{ "foo": 1, "bar": [1,2] }
```

should be converted to this:

```
[["foo", 1], ["bar", [1,2]]]
```

This is an unfortunate inconvenience, although many languages can convert this tuple array format
back into a dictionary for you to make it easier to work with on the other end, for example
`dict(**array)` in Python or `Hash[array]` in Ruby.
