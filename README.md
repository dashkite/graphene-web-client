# Graphene Web Client

An implementation of the Graphene Client that targets the Web API.

## Example
You can start working with your collections in three lines of code.

```coffeescript
import * as Graphene from "@dashkite/graphene-web-client"

client = Graphene.Client.create()
Films = client.collection { db: address, collection: "films" }

# now you can work with your collection

film = await Films.get "the-godfather"

await Films.put "the-godfather",
 { film..., rating: 5 }
 
await Films.delete "the-godfather"
```
This assumes you've already created the dbs and collections you want to work with (e.g. through the DashKite Workspaces App).


## Client
```coffeescript
import * as Graphene from "@dashkite/graphene-web-client"

# create the Web client
client = Graphene.Client.create()
```

## Database
### Create
Create a new database. The database will be assigned a unique address when you create it. This returns a database object — see [Get](###Get) for more details.
```coffeescript
myDB = await client.db.create name: "My Database"
```
### Get
Retrieve a database object with properties like name, created, and updated.
```coffeescript
myDB = await client.db.get address
```
### Put
```coffeescript
# with a database object

myDB.name = "My Favorite Database"
await myDB.put()

# with the client

await client.db.put address, name: "My Favorite Database"
```
### Delete
```coffeescript
# with a database object

await myDB.delete()

# with the client

await client.db.delete address
```

## Collection 
### Create
Create a collection within a database by assigning the collection a byname unique to the database. This returns a collection object — see [Get](###Get) for more details.
```coffeescript
# with a database object

myCollection = await myDB.collection.create byname: "favorite-films"

# with the client

myCollectionObject = await (client.db address).collection.create byname: "favorite-films"
```
### Get
Retrieve a collection object with properties like status, created, and updated.
```coffeescript
# with a database object

myCollection = await myDB.collection.get "favorite-films"

# with the client

myCollection = await (client.db address).collection.get "favorite-films"
```
### Put
```coffeescript
# with a database object

await myDB.collection.put "favorite-films", name: "Fave Films"

# with the client

await (client.db address).collection.put "favorite-films", name: "Fave Films"

# with a collection object

myCollection.name = "Fave Films"
await myCollection.put()
```
### Delete
```coffeescript
# with a database object

await myDB.collection.delete "favorite-films"

# with the client

await (client.db address).collection.delete "favorite-films"

# with a collection object

await myCollection.delete()
```
### Get Status
```coffeescript
# with a database object

{ status } = await myDB.collection.getStatus "favorite-films"

# with the client

{ status } = await (client.db address).collection.getStatus "favorite-films"

# with a collection object

{ status } = await myCollection.getStatus()
```
### List
```coffeescript
# with a database object

collections = await myDB.collection.list()

# with the client

collections = await (client.db address).collection.list()
```
## Entries and Indices
There are four ways to begin working with a collection's entry content, entry metadata, and indices.
```coffeescript
# with a database object

Films = myDB.collection "favorite-films"

# with the client 

Films = (client.db address).collection "favorite-films"

# with a shortcut

Films = client.collection { db: address, collection: "favorite-films" }

# with a collection object

Films = myCollection.entries
```
### Entry Content
```coffeescript
# get the content for an entry

film = await Films.get key
```
### Entry Metadata

```coffeescript
# get the metadata and content for an entry

filmWithMetadata = await Films.metadata.get key
```
### Indices
```coffeescript
# create an index on the collection

index = await Films.indices.create { key, sort }
```
