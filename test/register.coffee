typeSystem = require '../public/typeSystem'
should = require 'should'

describe 'typeSystem', ->

  describe 'register', ->

    it 'should register the name of a type', ->
      type = newtype: name: 'Type'

      system = typeSystem.init()

      error = system.register type
      should.not.exist error

      Object.keys(system.types).should.containEql type.newtype.name

    it 'should register a interface', ->
      interFace = newinterface: name: 'Interface'

      system = typeSystem.init()
      error = system.register interFace
      should.not.exist error

      Object.keys(system.interfaces).should.containEql interFace.newinterface.name

    it 'should not register the same name twice', ->
      type = newtype: name: 'Type'
      type2 = newtype: name: 'Type'

      system = typeSystem.init()

      error = system.register type
      should.not.exist error

      system.register(type2).should.eql "'Type' is already registered as a type", "validation failed"

      interFace = newinterface: name: 'Interface'
      interFace2 = newinterface: name: 'Interface'

      error2 = system.register interFace
      should.not.exist error2

      system.register(interFace2).should.eql "'Interface' is already registered as a interface"

      type3 = newtype: name: 'Interface'
      system.register(type3).should.eql "'Interface' is already registered as a interface", "cross comparison failed"

      interFace3 = newinterface: name: 'Type'
      system.register(interFace3).should.eql "'Type' is already registered as a type"

    it 'should enforce capitalization', ->
      type = newtype: name: 'type'
      interFace = newinterface: name: 'interface'
      type2 = newtype: name: '1Type'
      interFace2 = newinterface: name: '1Interface'
      system = typeSystem.init()
      system.register(type).should.eql 'Type names must begin with a capital letter'
      system.register(interFace).should.eql 'Interface names must begin with a capital letter'
      system.register(type2).should.eql 'Type names must begin with a capital letter'
      system.register(interFace2).should.eql 'Interface names must begin with a capital letter'

    it 'should let you register a type with Int fields', ->
      system = typeSystem.init()

      type = newtype:
        name: 'BasicType'
        fields: [
          aField: 'Int'
        ]

      error = system.register type
      should.not.exist error
