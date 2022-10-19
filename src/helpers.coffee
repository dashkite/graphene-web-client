import * as Fn from "@dashkite/joy/function"
import * as Type from "@dashkite/joy/type"
import * as Meta from "@dashkite/joy/metaclass"

timestamps = Meta.getters
  created: -> @_.created
  updated: -> @_.updated

proxy = ( name, target, methods ) ->
  Meta.getters
    [ name ]: ->
      parent = @
      new Proxy target,
        get: ( target, name, receiver ) ->
          if ( name in methods ) && ( Type.isFunction target[ name ] )
            (args...) -> target[ name ].apply @, [ parent, args... ]
          else
            Reflect.get target, name, receiver
          
invoke = Fn.tee ( type ) ->

  root = ( target ) ->
    while target.parent?
      target = target.parent
    target

  type.invoke = ( parent, request ) ->
    ( root parent ).invoke request

  type::invoke = ( request ) ->
    @constructor.invoke @parent, request

wrap = Fn.tee ( type ) ->

  type.wrap = ( parent, data ) ->
    if Type.isObject data
      Object.assign ( new @ ), { _: data, parent }
    else if Type.isArray data
      Object.assign ( new @List ), { _: data, parent }
    else if data?
      throw new TypeError "Unexpected response type"

  type.unwrap = ( object ) -> object._
  
  type::wrap = ( data ) -> @constructor.wrap @parent, data
  type::unwrap = -> @constructor.unwrap @

export {
  proxy
  invoke
  wrap
  timestamps
}