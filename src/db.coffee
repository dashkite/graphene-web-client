import { Resource } from "@dashkite/vega-client"
import * as M from "@dashkite/joy/metaclass"
import { Collection } from "./collection"
import { Entry } from "./entry"

class Meta extends Function

  @make: ( client ) ->
    Object.assign (new @), { client }

  create: ({ name }) ->
    Instance.make
      meta: @
      instance: await Resource.post
        origin: @client.base
        name: "db create"
        content: { name }

  get: ( address ) ->
    #TODO diff behavior based on status codes
    try
      Instance.make
        meta: @
        instance: await Resource.get 
          origin: @client.base
          name: "db"
          bindings: db: address

  put: ( address, { name }) ->
    #TODO what's going on with this put?
    Instance.make
      meta: @
      instance: await Resource.put 
        origin: @client.base
        name: "db"
        bindings: db: address
        content: { name }

  delete: ( address ) ->
    Resource.delete 
      origin: @client.base
      name: "db"
      bindings: db: address
    @


class Reference

  M.mixin @::, [
    M.getter "collection", -> Collection.proxy @meta.client, @address
  ]

  @make: ({ meta, address }) ->
    Object.assign (new @), { meta, address }

  get: ->
    @meta.get @address

  put: ({ name }) ->
    @meta.put @address, { name }

  delete: ->
    @meta.delete @address


class Instance

  M.mixin @::, [
    M.getter "address", -> @db
  ]

  @make: ({ meta, instance }) ->
    Object.assign (new @), { meta, instance... }

  put: ->
    @meta.put @address, { @name }

  delete: ->
    @meta.delete @address


proxy = ( client ) ->
  new Proxy (Meta.make client), 
    apply: ( meta, self, [ address ] ) ->
      Reference.make { meta, address }


DB = { Meta, Reference, Instance, proxy }
export { DB }