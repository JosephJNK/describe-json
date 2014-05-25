typeSystem = require '../public/typeSystem'
should = require 'should'

describe 'typeSystem', ->

  describe 'register', ->

    it 'should register the name of a type', ->
      type = newtype: name: 'Type'

      system = typeSystem.init()

      error = system.register type
      should.not.exist error

      Object.keys(system.types).should.includeEql type.newtype.name

    it 'should register a typeclass', ->
      typeClass = newtypeclass: name: 'Typeclass'

      system = typeSystem.init()
      error = system.register typeClass
      should.not.exist error

      Object.keys(system.typeclasses).should.includeEql typeClass.newtypeclass.name

    it 'should not register the same name twice', ->
      type = newtype: name: 'Type'
      type2 = newtype: name: 'Type'

      system = typeSystem.init()

      error = system.register type
      should.not.exist error

      system.register(type2).should.eql "'Type' is already registered as a type", "validation failed"

      typeClass = newtypeclass: name: 'Typeclass'
      typeClass2 = newtypeclass: name: 'Typeclass'

      error2 = system.register typeClass
      should.not.exist error2

      system.register(typeClass2).should.eql "'Typeclass' is already registered as a typeclass"

      type3 = newtype: name: 'Typeclass'
      system.register(type3).should.eql "'Typeclass' is already registered as a typeclass", "cross comparison failed"

      typeClass3 = newtypeclass: name: 'Type'
      system.register(typeClass3).should.eql "'Type' is already registered as a type"

    it 'should enforce capitalization', ->
      type = newtype: name: 'type'
      typeClass = newtypeclass: name: 'typeclass'
      type2 = newtype: name: '1Type'
      typeClass2 = newtypeclass: name: '1Typeclass'
      system = typeSystem.init()
      system.register(type).should.eql 'Type names must begin with a capital letter'
      system.register(typeClass).should.eql 'Typeclass names must begin with a capital letter'
      system.register(type2).should.eql 'Type names must begin with a capital letter'
      system.register(typeClass2).should.eql 'Typeclass names must begin with a capital letter'

    it 'should let you register a type with Int fields', ->
      system = typeSystem.init()

      type = newtype:
        name: 'BasicType'
        fields: [
          aField: 'Int'
        ]

      error = system.register type
      should.not.exist error
