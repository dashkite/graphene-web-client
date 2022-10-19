import { test as _test, success } from "@dashkite/amen"
import { print, debug } from "@dashkite/amen-console"
import assert from "@dashkite/assert"
import fetch from "node-fetch"
import * as Type from "@dashkite/joy/type"
import Registry from "@dashkite/helium"
import { Queue } from "@dashkite/joy/iterable"
import * as Time from "@dashkite/joy/time"

globalThis.fetch ?= fetch
global.Request ?= fetch.Request

# set up db and local storage that zinc depends upon
import "fake-indexeddb/auto"
import "./local-storage"
import * as Runes from "@dashkite/runes/client"

# MUT
import * as Graphene from "../src"
import { DB } from "../src/db"
import { Collection } from "../src/collection"
import { Entry } from "../src/entry"

import {
  getRune
} from "./helpers"

test = ( description, content ) ->
  _test { wait: false, description }, content

wait = ({ interval, predicate, action }) ->
  interval ?= 5
  loop
    break if predicate await action() 
    await Time.sleep interval * 1000

do ({ email, db, client, collection, entry } = {}) ->

  email = "alice@acme.org"

  localStorage.setItem "identity", email

  Registry.set { messages: Queue.create() }

  client = Graphene.Client.create()

  print await test "Graphene", [

    await test "Database", [
      
      await test "Create", ->
        db = await client.db.create name: "Test Web Client"

        assert db?
        assert db.address?
        assert.equal db.name, "Test Web Client"
        assert Type.isType DB.Instance, db

        Runes.store await getRune "db use", 
          email: email
          db: db.address

      await test "Get", ->
        db = await client.db.get db.address

        assert db.address?
        assert db.created?
        assert db.updated?
        assert.equal db.name, "Test Web Client"

      await test "Put", ->
        db = await client.db.put db.address, name: "My Updated Database" 

        assert db.address?
        assert db.created?
        assert db.updated?
        assert db.updated > db.created
        assert.equal db.name, "My Updated Database"

      await test "Implicit Get", ->
        db = client.db db.address
        
        assert db?
        assert db.address?
        assert Type.isType DB.Reference, db
    ]

    await test "Collection", [
      
      await test "Create", ->
        collection = await db.collection.create byname: "test-graphene-web-client"

        assert collection?
        assert collection.byname?
        assert.equal collection.byname, "test-graphene-web-client"
        assert Type.isType Collection.Instance, collection

      await test "Status (not ready)", ->
        { status } = await db.collection.getStatus collection.byname

        assert status?
        assert status == "not ready" || status == "ready"

      await test "Status (ready)", ->
        wait
          predicate: ( response ) -> 
            response.status == "ready"
          action: -> db.collection.getStatus collection.byname

      await test "Get", ->
        collection = await db.collection.get collection.byname
        
        assert collection?
        assert collection.byname?
        assert Type.isType Collection.Instance, collection

      await test "Put", ->
        collection = await db.collection.put collection.byname, name: "Favorite Shows And Films"
        
        assert collection.byname?
        assert collection.created?
        assert collection.updated?
        assert collection.updated > collection.created
        assert.equal collection.name, "Favorite Shows And Films"

      await test "List", ->
        collections = await db.collection.list()

        assert collections?
        assert.equal collections.length, 1
        assert.equal collections[0].collection, "test-graphene-web-client"
    ]

    await test "Entry", [

      await test "Create", ->
        collection = db.collection collection.byname
        entry = await collection.put "star-wars",
          title: "Star Wars"
          year: "1977"
          views: 0

        assert entry.content.title?
        assert.equal entry.content.title, "Star Wars"
        assert entry.content.year?
        assert.equal entry.content.year, "1977"

      await test "Get", ->
        entry = await collection.get "star-wars"

        assert entry.content.title?
        assert.equal entry.content.title, "Star Wars"
        assert entry.content.year?
        assert.equal entry.content.year, "1977"
      
      await test "Put", ->
        entry = await collection.put "star-wars",
          { entry.content..., director: "George Lucas" }

        assert entry.content.title?
        assert.equal entry.content.title, "Star Wars"
        assert entry.content.year?
        assert.equal entry.content.year, "1977"
        assert entry.content.director?
        assert.equal entry.content.director, "George Lucas"

      await test "Query", ->
        content = await collection.query title: "Star Wars"

        assert.equal content.director, "George Lucas"

      await test "Query All", ->
        content = await collection.queryAll title: "Star Wars"

        assert content.length?
        assert.equal 1, content.length
        assert.equal "Star Wars", content[ 0 ].title

      await test "List", ->
        entries = await collection.list()
      
        assert entries.length?
        assert.equal 1, entries.length
        assert.equal "Star Wars", entries[0].title

      await test "Increment", ->
        { views } = await collection.increment "star-wars", "views"
        assert.equal 1, views

      await test "Decrement", ->
        { views } = await collection.decrement "star-wars", "views"
        assert.equal 0, views

      await test "Implicit Get", ->
        entry = collection entry.key
        assert entry?
        assert entry.key?
        assert Type.isType Entry.Reference, entry

    ]

    await test "Metadata", [
      
      await test "Get", ->
        entry = await collection.metadata.get "star-wars"

        assert.equal "star-wars", entry.key
        assert entry.content?
        data = entry.content
        assert data.title?
        assert.equal data.title, "Star Wars"
        assert data.year?
        assert.equal data.year, "1977"

      await test "List", ->
        entries = await collection.metadata.list()

        assert entries.length?
        assert.equal 1, entries.length
        assert.equal "Star Wars", entries[0].content.title
        assert.equal "star-wars", entries[0].entry

      await test "Query", ->
        entry = await collection.metadata.query title: "Star Wars"

        assert entry?.content?
        data = entry.content
        assert.equal data.director, "George Lucas"

      await test "Query All", ->
        entries = await collection.metadata.queryAll title: "Star Wars"

        assert entries?.length?
        assert.equal 1, entries.length
        assert.equal "Star Wars", entries[ 0 ].content.title
    ]

    await test "Indexing", await do ->
      key = "title"
      sort = "year"
  
      [
        await test "Create", ->
          index = await collection.indices.create { key, sort }

          assert.equal key, index.key
          assert.equal sort, index.sort
          assert.equal "not ready", index.status

        # await test "Get", ->
        #   index = await collection.indices.get { key, sort }   

        #   console.log index
        #   assert.equal key, index.key
        #   assert.equal sort, index.sort

        # await test "Status (ready)", ->
        #   wait
        #     interval: 30
        #     predicate: ( index ) -> 
        #       index.status == "ready"
        #     action: ->
        #       collection.indices.get { key, sort }

        await test "List", ->
          indices = await collection.indices.list()     

          assert.equal 1, indices.length
          # assert.equal "ready", indices[0].status
          assert.equal key, indices[0].key
          assert.equal sort, indices[0].sort

      ]

    await test "Entry", [
      
      await test "Delete", ->
        collection.delete "star-wars"

      await test "Get (After Delete)", ->
        wait
          predicate: ( response ) ->
            !content?
          action: ->
            content = await collection.get "star-wars"
    ]

    # await test "Collection", [

    #   await test "Delete", ->
    #     db.collection.delete "test-graphene-web-client"

    #   await test "Get (After Delete)", ->

    #     wait
    #       predicate: ( response ) -> 
    #         !collection?
    #       action: ->
    #         collection = await db.collection.get "test-graphene-web-client"
    # ]

    await test "DB", [

      await test "Delete", ->
        db.delete()

      await test "Get (After Delete)", ->
        wait
          predicate: ( response ) ->
            !db?
          action: ->
            db = await client.db.get db.address

      ]

  ]
