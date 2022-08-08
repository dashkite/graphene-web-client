import * as Fn from "@dashkite/joy/function"
import * as Meta from "@dashkite/joy/metaclass"

import {
  invoke
  wrap
} from "./helpers"

class List

  Meta.mixin @, [
    invoke
    wrap
  ]

class Entry

  @List: List

  Meta.mixin @, [
    invoke
    wrap
  ]

  @get: (parent, entry ) ->
    try
      @invoke parent,
        resource: 
          name: "entry"
          bindings: { db: parent.db, collection: parent.collection, entry }
        method: "get"

  @put: ( parent, entry, content ) ->
    @invoke parent,
      resource: 
        name: "entry"
        bindings: { db: parent.db, collection: parent.collection, entry }
      content: content
      method: "put"

  @list: ( parent ) ->
    @invoke parent,
      resource:
        name: "entry list"
        bindings: { db: parent.db, collection: parent.collection }
      method: "get"

  @query: ( parent, query ) ->
    @invoke parent,
      resource: 
        name: "query"
        bindings: { db: parent.db, collection: parent.collection, query  }
      method: "get"

  @delete: ( parent, entry ) ->
    { db, collection } = parent
    @invoke parent,
      resource:
        name: "entry"
        bindings: { db, collection, entry }
      method: "delete"

class Entries
  @fromConfiguration: ( client, configuration ) ->
    do Fn.flow [
      -> client.db.get configuration.db
      ( db ) -> db.collections.get configuration.collection
      (collection) -> collection.entries
    ]


export { Entry, Entries }