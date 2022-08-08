import * as Meta from "@dashkite/joy/metaclass"

import {
  proxy
  invoke
  wrap
  timestamps
} from "./helpers"

import { Entry } from "./entry"
import { Metadata } from "./metadata"

class Collection

  Meta.mixin @, [
    invoke, wrap
  ]

  Meta.mixin @::, [

    proxy "entries", Entry, [ "get", "put", "delete", "list", "query" ]
    proxy "metadata", Metadata, [ "get", "put", "delete", "list", "query" ]
    timestamps

    Meta.getters
      db: -> @_.db
      collection: -> @_.collection
      byname: -> @_.collection
      name: -> @_.name
  ]

  @create: ( parent, collection, { name }) ->
    @wrap parent, await do =>
      @invoke parent,
        resource: 
          name: "collections"
          bindings: { db: parent.db }
        content: { name, collection }
        method: "post"

  @get: ( parent, collection ) ->
    @wrap parent, await do =>
      try
        @invoke parent,
          resource: 
            name: "collection"
            bindings: { db: parent.db, collection }
          method: "get"

  getStatus: ->
    @invoke
      resource: 
        name: "collection status"
        bindings: { @db, @collection }
      method: "get"

  put: ({ name }) ->
    @wrap await do =>
      @invoke
        resource: 
          name: "collection"
          bindings: { @db, @collection }
        content: { name }          
        method: "put"

export { Collection }