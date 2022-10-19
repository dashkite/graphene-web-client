import { Resource } from "@dashkite/vega-client"
import * as M from "@dashkite/joy/metaclass"
import { Entry } from "./entry"

class Meta extends Function

  @make: ({ client, db }) ->
    Object.assign (new @), { client, db }

  create: ({ byname, name }) ->
    Instance.make
      meta: @
      instance: await Resource.post
        origin: @client.base
        name: "collections"
        bindings: { @db }
        content: { collection: byname, name }

  get: ( byname ) ->
    #TODO diff behavior based on status codes
    try
      Instance.make
        meta: @
        instance: await Resource.get 
          origin: @client.base
          name: "collection"
          bindings: { @db, collection: byname }

  put: ( byname, { name }) ->
    #TODO what's going on with this put?
    Instance.make
      meta: @
      instance: await Resource.put 
        origin: @client.base
        name: "collection"
        bindings: { @db, collection: byname }
        content: { name }

  delete: ( byname ) ->
    Resource.delete 
      origin: @client.base
      name: "collection"
      bindings: { @db, collection: byname }
    @

  getStatus: ( byname ) ->
    Resource.get
      origin: @client.base
      name: "collection status"
      bindings: { @db, collection: byname }

  list: ->
    Resource.get
      origin: @client.base
      name: "collections"
      bindings: { @db }


class Reference

  M.mixin @::, [
    M.getter "entries", -> Entry.proxy @meta.client, @meta.db, @byname
  ]

  @make: ({ meta, byname }) ->
    Object.assign (new @), { meta, byname }

  get: ->
    @meta.get @byname

  put: ({ name }) ->
    @meta.put @byname, { name }

  delete: ->
    @meta.delete @byname
  
  getStatus: ->
    @meta.getStatus @byname

  list: ->
    @meta.list()


class Instance

  M.mixin @::, [
    M.getter "byname", -> @collection
  ]

  @make: ({ meta, instance }) ->
    Object.assign (new @), { meta, instance... }

  put: ->
    @meta.put @byname, { @name }

  delete: ->
    @meta.delete @byname

  getStatus: ->
    @meta.getStatus @byname

  list: ->
    @meta.list()


proxy = ( client, db ) ->
  new Proxy (Meta.make { client, db }), 
    apply: ( meta, self, [ byname ] ) ->
      (Reference.make { meta, byname }).entries


Collection = { Meta, Reference, Instance, proxy }
export { Collection }