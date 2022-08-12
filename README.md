# Graphene Web Client

An implementation of the Graphene Client that targets the Web API.

```coffeescript
import * as Graphene from "@dashkite/graphene-web-client"

# create the Web client
client = Graphene.Client.create base: "https://graphene.dashkite.io"

# create a new database
# the database will have a unique address
db = await client.db.create name: "My Database"

# create a collection within the database
# assign the collection a byname unique to the database
collection = await db.collections.create "favorite-films"
  name: "Favorite Films"

# wait for it to be ready
while ( await collection.getStatus() ).status != "ready"
  await Time.sleep 1000

# let's add something to our collection!
films = collection.entries

# start with a classic
await films.put "star-wars",
  title: "Star Wars"
  year: "1977"
  
data = await films.get "star-wars"

# update it to include the director
await films.put "star-wars",
  { data..., director: "George Lucas}
```
