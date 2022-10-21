# Graphene Web Client

An implementation of the Graphene Client that targets the Web API.

## Example
You can start working with your collections in three lines of code, if you've already created the db and collections you want to work with (e.g., through the DashKite Workspaces App).

```coffeescript
import * as Graphene from "@dashkite/graphene-web-client"

client = Graphene.Client.create()
Films = client.collection { db: address, collection: "films" }

# now you can work with your collection

film = await Films.get "the-godfather"

await Films.put "the-godfather",
 { film..., rating: 5 }
```

## Client
```coffeescript
import * as Graphene from "@dashkite/graphene-web-client"

# create the Web client
client = Graphene.Client.create()
```

## Database
```coffeescript
# the database will be assigned a unique address when you create it

# create a new database (this returns a database object — see "get" for more details)

myDBObject = await client.db.create name: "My Database"

# get a database object with properties like name, created, and updated

myDBObject = await client.db.get address

# store a database address for future use

myDBReference = client.db address
```

## Collection 
For each collection scenario we can use either a database object, database reference, or shortcut to achieve our goal.
```coffeescript

# create a collection within the database (this returns a collection object — see "get" for more details)
# assign the collection a byname unique to the database

myCollectionObject = await myDBObject.collection.create byname: "favorite-films"
myCollectionObject = await myDBReference.collection.create byname: "favorite-films"

# get a collection object with properties like status, created, and updated

myCollectionObject = await myDBObject.collection.get "favorite-films"
myCollectionObject = await myDBReference.collection.get "favorite-films"

# store a collection byname and associated db address for future use

myCollectionReference = myDBObject.collection "favorite-films"
myCollectionReference = myDBReference.collection "favorite-films"
myCollectionReference = client.collection { db: address, collection: "favorite-films" } # shortcut
```

## Entries, Indices, and Metadata 
We can use either a collection object or collection reference to achieve our goals.
```coffeescript
# get the content for an entry

entryContent = await myCollectionObject.entries.get key
entryContent = await myCollectionReference.get key

# create an index on the collection

index = await myCollectionObject.entries.indices.create { key, sort }
index = await myCollectionReference.indices.create { key, sort }

# get the metadata and content for an entry

entryWithMetadata = await myCollectionObject.entries.metadata.get key
entryWithMetadata = await myCollectionReference.metadata.get key
```
