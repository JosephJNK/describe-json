resolve = require '../src/resolveTypeGraph'
typeSystem = require '../src/typeSystem'

describe.skip 'resolveTypeGraph', ->

  it 'should handle inherited fields', ->

    memberType =
      newtype:
        name: 'MemberType'
        typeclasses: ['TypeclassWithField']
        fields: [
          ownField: 'Int'
        ]

    typeclassWithField =
      newtypeclass:
        name: 'TypeclassWithField'
        fields: [
          classField: 'String'
        ]

    system = typeSystem.init()
    system.register memberType
    system.register typeclassWithField

    resolvedForms = resolve system.types, system.typeclasses

    resolvedForms.typefields.should.eql {
      'MemberType':
        ownField: 'Int'
        classField: 'String'
    }

    resolvedForms.typeclassmembers.should.eql {
      'TypeclassWithField': [ 'MemberType' ]
    }
