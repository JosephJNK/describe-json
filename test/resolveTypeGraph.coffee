resolve = require '../src/resolveTypeGraph'
typeSystem = require '../src/typeSystem'

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
        extends: 'ParentTypeclass'
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

    resolvedForms = resolve system.types, system.typeclasses

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
