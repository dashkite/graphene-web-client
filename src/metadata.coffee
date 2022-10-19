import { Resource } from "@dashkite/vega-client"
import * as M from "@dashkite/joy/metaclass"
import { Index } from "./indices"

class Meta extends Function

  @make: ({ client, db, collection }) ->
    Object.assign (new @), { client, db, collection }

  get: ( key ) ->
    Instance.make
      meta: @
      instance: await Resource.get 
        origin: @client.base
        name: "metadata"
        bindings: { @db, @collection, entry: key }

  query: ( query ) ->
    Resource.get
      origin: @client.base
      name: "metadata query"
      bindings: { @db, @collection, query }

  queryAll: ( query ) ->
    Resource.get
      origin: @client.base
      name: "metadata query all"
      bindings: { @db, @collection, query }

  list: ->
    Resource.get
      origin: @client.base
      name: "metadata list"
      bindings: { @db, @collection }


class Reference

  @make: ({ meta, key }) ->
    Object.assign (new @), { meta, key }

  get: ->
    @meta.get @key

  query: ( query ) ->
    @meta.query query

  queryAll: ( query ) ->
    @meta.queryAll query

  list: ->
    @meta.list()


class Instance

  M.mixin @::, [
    M.getter "key", -> @entry
  ]

  @make: ({ meta, instance }) ->
    Object.assign (new @), { meta, instance... }

  query: ( query ) ->
    @meta.query query

  queryAll: ( query ) ->
    @meta.queryAll query

  list: ->
    @meta.list()


proxy = ( client, db, collection ) ->
  new Proxy (Meta.make { client, db, collection }), 
    apply: ( meta, self, [ key ] ) ->
      Reference.make { meta, key }


Metadata = { Meta, Reference, Instance, proxy }
export { Metadata }