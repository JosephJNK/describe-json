resolve = require '../src/resolveTypeGraph'
typeSystem = require '../src/typeSystem'
should = require 'should'

{inspect} = require 'util'

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


  it 'should let polymorphic fields be inherited from typeclasses', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        innerParameterized: 'fieldParameter'

    wrapperTypeclass = newtypeclass:
      name: 'WrapperTypeclass'
      typeparameters: ['passedThroughParameter', 'ownParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'passedThroughParameter'
        polymorphicField: 'ownParameter'

    outerType = newtype:
      name: 'OuterType'
      typeclasses: [ {
        'WrapperTypeclass': { passedThroughParameter: 'String', ownParameter: 'Integer'}
      } ]
      fields:
        ownField: 'Number'

    system = typeSystem.init()
    system.register parameterizedType
    system.register wrapperTypeclass
    system.register outerType

    [err, resolvedForms] = resolve system.types, system.typeclasses
    should.not.exist err

    resolvedForms.typefields.OuterType.should.eql
      ownField: 'Number'
      parameterizedField:
        'ParameterizedType':
          fieldParameter: 'String'
      polymorphicField: 'Integer'

    resolvedForms.typeclassmembers.should.eql {
      'WrapperTypeclass': [ 'OuterType' ]
    }

  it 'should let typeclasses pass parameters to the typeclasses they extend', ->

    outerTypeclassA = newtypeclass:
      name: 'OuterTypeclassA'
      typeparameters: ['aParameter']
      fields:
        aField: 'aParameter'

    outerTypeclassB = newtypeclass:
      name: 'OuterTypeclassB'
      typeparameters: ['bParameter']
      fields:
        bField: 'bParameter'

    innerTypeclass = newtypeclass:
      name: 'InnerTypeclass'
      extends: [
        {'OuterTypeclassA': aParameter: 'innerParam'},
        {'OuterTypeclassB': bParameter: 'innerParam'}
      ]
      typeparameters: ['innerParam']

    aType = newtype:
      name: 'AType'
      typeclasses: [ {
        'InnerTypeclass': { innerParam: 'Integer'}
      } ]

    system = typeSystem.init()
    system.register outerTypeclassA
    system.register outerTypeclassB
    system.register innerTypeclass
    system.register aType

    [err, resolvedForms] = resolve system.types, system.typeclasses
    should.not.exist err

    console.log "resolvedForms:\n#{inspect resolvedForms, depth: null}"

    resolvedForms.typefields.AType.should.eql
      aField: 'Integer'
      bField: 'Integer'

    resolvedForms.typeclassmembers.should.eql
      'OuterTypeclassA': [ 'AType' ]
      'OuterTypeclassB': [ 'AType' ]
      'InnerTypeclass': [ 'AType' ]

