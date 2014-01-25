resolve = require '../src/resolveTypeGraph'
typeSystem = require '../src/typeSystem'
should = require 'should'

describe 'resolveTypeGraph', ->

  it 'should handle inherited fields', ->

    memberType =
      newtype:
        name: 'MemberType'
        typeclasses: ['TypeclassWithField']
        fields:
          ownField: 'Int'

    typeclassWithField =
      newtypeclass:
        name: 'TypeclassWithField'
        extends: ['ParentTypeclass']
        fields:
          classField: 'String'

    parentTypeclass =
      newtypeclass:
        name: 'ParentTypeclass'
        fields:
          parentField: 'Number'

    system = typeSystem.init()
    system.register memberType
    system.register typeclassWithField
    system.register parentTypeclass

    [err, resolvedForms] = resolve system.types, system.typeclasses
    should.not.exist err

    {inspect} = require 'util'

    resolvedForms.typefields.should.eql {
      'MemberType':
        ownField: 'Int'
        classField: 'String'
        parentField: 'Number'
    }

    resolvedForms.typeclassmembers.should.eql {
      'TypeclassWithField': [ 'MemberType' ]
      'ParentTypeclass': [ 'MemberType' ]
    }
