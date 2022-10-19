import * as Meta from "@dashkite/joy/metaclass"
import configuration from "./configuration"
import { DB } from "./db"

class Client

  @create: ({ base } = {}) ->
    base ?= configuration.base
    Object.assign ( new @ ), { base }

  Meta.mixin @::, [
    Meta.getter "db", -> DB.proxy @
  ]

    
export { Client }