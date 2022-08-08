import * as Meta from "@dashkite/joy/metaclass"

import {
  proxy
  invoke
  wrap
  timestamps
} from "./helpers"

import { Collection } from "./collection"

class DB

  Meta.mixin @, [ invoke, wrap ]

  Meta.mixin @::, [

    proxy "collections", Collection, [ "create", "get", "getStatus" ]

    timestamps

    Meta.getters
      address: -> @_.db
      db: -> @_.db
      name: -> @_.name
  ]

  @create: ( client, { name }) ->
    @wrap client, await do =>
      @invoke client,
        resource: 
          name: "db create"
        method: "post"
        content: { name }

  @get: ( client, db ) ->
    @wrap client, await do =>
      try
        @invoke client,
          resource: 
            name: "db"
            bindings: { db }
          method: "get"

  put: ({ name }) ->
    @wrap await do =>
      @invoke
        resource: 
          name: "db"
          bindings: { @db }
        content: { name }       
        method: "put"

export { DB }