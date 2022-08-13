import fetch from "node-fetch"
globalThis.fetch ?= fetch
global.Request ?= fetch.Request

# set up db and local storage that zinc depends upon
import "fake-indexeddb/auto"
import "./local-storage"
import * as Runes from "@dashkite/runes/client"

# MUT
import * as Graphene from "../src"

import {
  getRune
} from "./helpers"

import run from "@dashkite/graphene-client-tests"

do ({ email, client } = {}) ->

  email = "alice@acme.org"

  localStorage.setItem "identity", email
  # Runes.store await getRune "db create", { email }

  client = Graphene.Client.create()

  run client,
    Database:
      Create: ( db ) ->
        Runes.store await getRune "db use", 
          email: email
          db: db.address

