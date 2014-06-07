resolve = require '../public/resolveTypeGraph'
typeSystem = require '../public/typeSystem'
should = require 'should'

{inspect} = require 'util'

describe 'resolveTypeGraph', ->

  it 'should handle inherited fields', ->

    memberType =
      newtype:
        name: 'MemberType'
        interfaces: ['InterfaceWithField']
        fields:
          ownField: 'Int'

    interfaceWithField =
      newinterface:
        name: 'InterfaceWithField'
        extends: ['ParentInterface']
        fields:
          classField: 'String'

    parentInterface =
      newinterface:
        name: 'ParentInterface'
        fields:
          parentField: 'Number'

    system = typeSystem.init()
    system.register memberType
    system.register interfaceWithField
    system.register parentInterface

    [err, resolvedForms] = resolve system.types, system.interfaces
    should.not.exist err

    resolvedForms.typefields.should.eql {
      'MemberType':
        ownField: 'Int'
        classField: 'String'
        parentField: 'Number'
    }

    resolvedForms.interfacemembers.should.eql {
      'InterfaceWithField': [ 'MemberType' ]
      'ParentInterface': [ 'MemberType' ]
    }


  it 'should let polymorphic fields be inherited from interfaces', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        innerParameterized: 'fieldParameter'

    wrapperInterface = newinterface:
      name: 'WrapperInterface'
      typeparameters: ['passedThroughParameter', 'ownParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'passedThroughParameter'
        polymorphicField: 'ownParameter'

    outerType = newtype:
      name: 'OuterType'
      interfaces: [ {
        'WrapperInterface': { passedThroughParameter: 'String', ownParameter: 'Integer'}
      } ]
      fields:
        ownField: 'Number'

    system = typeSystem.init()
    system.register parameterizedType
    system.register wrapperInterface
    system.register outerType

    [err, resolvedForms] = resolve system.types, system.interfaces
    should.not.exist err

    resolvedForms.typefields.OuterType.should.eql
      ownField: 'Number'
      parameterizedField:
        'ParameterizedType':
          fieldParameter: 'String'
      polymorphicField: 'Integer'

    resolvedForms.interfacemembers.should.eql {
      'WrapperInterface': [ 'OuterType' ]
    }

  it 'should let interfaces pass parameters to the interfaces they extend', ->

    outerInterfaceA = newinterface:
      name: 'OuterInterfaceA'
      typeparameters: ['aParameter']
      fields:
        aField: 'aParameter'

    outerInterfaceB = newinterface:
      name: 'OuterInterfaceB'
      typeparameters: ['bParameter']
      fields:
        bField: 'bParameter'

    innerInterface = newinterface:
      name: 'InnerInterface'
      extends: [
        {'OuterInterfaceA': aParameter: 'innerParam'},
        {'OuterInterfaceB': bParameter: 'innerParam'}
      ]
      typeparameters: ['innerParam']

    aType = newtype:
      name: 'AType'
      interfaces: [ {
        'InnerInterface': { innerParam: 'Integer'}
      } ]

    system = typeSystem.init()
    system.register outerInterfaceA
    system.register outerInterfaceB
    system.register innerInterface
    system.register aType

    [err, resolvedForms] = resolve system.types, system.interfaces
    should.not.exist err

    resolvedForms.typefields.AType.should.eql
      aField: 'Integer'
      bField: 'Integer'

    resolvedForms.interfacemembers.should.eql
      'OuterInterfaceA': [ 'AType' ]
      'OuterInterfaceB': [ 'AType' ]
      'InnerInterface': [ 'AType' ]
