import { Resource } from "@dashkite/vega-client"
import * as M from "@dashkite/joy/metaclass"
import { Index } from "./indices"
import { Metadata } from "./metadata"

class Meta extends Function

  M.mixin @::, [
    M.getter "indices", -> Index.Meta.make { @client, @db, @collection }
  ]

  M.mixin @::, [
    M.getter "metadata", -> Metadata.Meta.make { @client, @db, @collection }
  ]

  @make: ({ client, db, collection }) ->
    Object.assign (new @), { client, db, collection }

  get: ( key ) ->
    #TODO diff behavior based on status codes
    try
      Instance.make
        meta: @
        instance: 
          content: await Resource.get 
            origin: @client.base
            name: "entry"
            bindings: { @db, @collection, entry: key }
          key: key

  put: ( key, content ) ->
    Instance.make
      meta: @
      instance: 
        content: await Resource.put 
          origin: @client.base
          name: "entry"
          bindings: { @db, @collection, entry: key }
          content: content
        key: key

  delete: ( key ) ->
    Resource.delete 
      origin: @client.base
      name: "entry"
      bindings: { @db, @collection, entry: key }
    @

  query: ( query ) ->
    Resource.get
      origin: @client.base
      name: "entry query"
      bindings: { @db, @collection, query }

  queryAll: ( query ) ->
    Resource.get
      origin: @client.base
      name: "entry query all"
      bindings: { @db, @collection, query }

  list: ->
    Resource.get
      origin: @client.base
      name: "entry list"
      bindings: { @db, @collection }

  increment: ( key, property ) ->
    { content } = await Resource.post
      origin: @client.base
      name: "atomic update"
      bindings: { @db, @collection, entry: key, property, expression: "+1" }
    content

  decrement: ( key, property ) ->
    { content } = await Resource.post
      origin: @client.base
      name: "atomic update"
      bindings: { @db, @collection, entry: key, property, expression: "-1" }
    content


class Reference

  @make: ({ meta, key }) ->
    Object.assign (new @), { meta, key }

  get: ->
    @meta.get @key

  put: ( content ) ->
    @meta.put @key, content

  delete: ->
    @meta.delete @key

  query: ( query ) ->
    @meta.query query

  queryAll: ( query ) ->
    @meta.queryAll query

  list: ->
    @meta.list()

  increment: ( property ) ->
    @meta.increment @key, property

  decrement: ( property ) ->
    @meta.decrement @key, property


class Instance

  @make: ({ meta, instance }) ->
    Object.assign (new @), { meta, instance... }

  put: ->
    @meta.put @key, @content

  delete: ->
    @meta.delete @key

  query: ( query ) ->
    @meta.query query

  queryAll: ( query ) ->
    @meta.queryAll query

  list: ->
    @meta.list()

  increment: ( property ) ->
    @meta.increment @key, property

  decrement: ( property ) ->
    @meta.decrement @key, property


proxy = ( client, db, collection ) ->
  new Proxy (Meta.make { client, db, collection }), 
    apply: ( meta, self, [ key ] ) ->
      Reference.make { meta, key }


Entry = { Meta, Reference, Instance, proxy }
export { Entry }