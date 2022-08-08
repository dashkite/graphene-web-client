import * as Fn from "@dashkite/joy/function"
import * as Meta from "@dashkite/joy/metaclass"
import { convert } from "@dashkite/bake"
import { Resource } from "@dashkite/vega-client"

import {
  proxy
} from "./helpers"

import { DB } from "./db"

class Client

  Meta.mixin @::, [
    proxy "db", DB, [ "create", "get" ]
  ]

  @create: ({ base }) ->
    Object.assign ( new @ ), { base }

  invoke: ({ method, resource, content }) ->
    resource = await Resource.create {
      origin: @base
      name: resource.name
      bindings: resource.bindings
      authorization: { @rune, @nonce }
    }
    ( resource[ method ] content )
    
export { Client }