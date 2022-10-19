import { Resource } from "@dashkite/vega-client"
import * as M from "@dashkite/joy/metaclass"

class Meta extends Function

  @make: ({ client, db, collection }) ->
    Object.assign (new @), { client, db, collection }

  create: ({ key, sort }) ->
    Instance.make
      meta: @
      instance: await Resource.post
        origin: @client.base
        name: "collection indices"
        bindings: { @db, @collection }
        content: { key, sort }

  get: ({ key, sort }) ->

    console.log await Resource.get
      origin: @client.base
      name: "collection index"
      bindings: { @db, @collection, key, sort }
    Instance.make
      meta: @
      instance: await Resource.get
        origin: @client.base
        name: "collection index"
        bindings: { @db, @collection, key, sort }

  delete: ({ key, sort }) ->
    Resource.delete
      origin: @client.base
      name: "collection index"
      bindings: { @db, @collection, key, sort }

  list: ->
    Resource.get
      origin: @client.base
      name: "collection indices"
      bindings: { @db, @collection }


class Instance

  @make: ({ meta, instance }) ->
    Object.assign (new @), { meta, instance... }

  delete: ->
    @meta.delete { @key, @sort }

  list: ->
    @meta.list()


Index = { Meta, Instance }
export { Index }