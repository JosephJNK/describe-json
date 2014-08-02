recognizer = require '../public/recognizer'
typeSystem = require '../public/typeSystem'
should = require 'should'

{inspect} = require 'util'

describe 'type parameters', ->

  it 'should be registerable with the type system', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    system = typeSystem.init()
    error = system.register parameterizedType

    should.not.exist error

    system.types.ParameterizedType.should.eql parameterizedType.newtype

  it 'should allow for a types fields to vary across containers', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    numberOuterType = newtype:
      name: 'NumberOuterType'
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'Number'
        nonparameterizedField: 'String'

    stringOuterType = newtype:
      name: 'StringOuterType'
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'String'
        nonparameterizedField: 'Number'

    system = typeSystem.init()
    system.register numberOuterType
    system.register parameterizedType
    system.register stringOuterType

    system.generateParsers()
    recognize = system.getRecognizer()

    firstData =
      parameterizedField:
        intField: 1
        innerParameterized: 1.5
      nonparameterizedField: 'foo'

    firstMatched = recognize 'NumberOuterType', firstData

    firstMatched.should.match
      matched: true
      data: firstData
      typedata:
        type: 'NumberOuterType'
        typeparameters: {}
        iscontainer: true
        fields:
          parameterizedField:
            type: 'ParameterizedType'
            typeparameters: {fieldParameter: 'Number'}
            iscontainer: true
            fields:
              intField:
                type: 'Integer'
                iscontainer: false
              innerParameterized:
                type: 'Number'
                iscontainer: false
          nonparameterizedField:
            type: 'String'
            iscontainer: false

    secondData =
      parameterizedField:
        intField: 1
        innerParameterized: 'bar'
      nonparameterizedField: -2

    secondMatched = recognize 'StringOuterType', secondData

    secondMatched.should.match
      matched: true
      data: secondData
      typedata:
        type: 'StringOuterType'
        typeparameters: {}
        iscontainer: true
        fields:
          parameterizedField:
            type: 'ParameterizedType'
            typeparameters: {fieldParameter: 'String'}
            iscontainer: true
            fields:
              intField:
                type: 'Integer'
                iscontainer: false
              innerParameterized:
                type: 'String'
                iscontainer: false
          nonparameterizedField:
            type: 'Number'
            iscontainer: false

  it 'should let a interface contain a parametric type', ->

    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['fieldParameter']
      fields:
        intField: 'Integer'
        innerParameterized: 'fieldParameter'

    wrapperInterface = newinterface:
      name: 'WrapperInterface'
      typeparameters: ['passedThroughParameter', 'ownParameter']
      fields:
        parameterizedField:
          'ParameterizedType':
            fieldParameter: 'passedThroughParameter'
        polymorphicField: 'ownParameter'
        floatField: 'Float'

    outerType = newtype:
      name: 'OuterType'
      interfaces: [ {
        'WrapperInterface': { passedThroughParameter: 'String', ownParameter: 'Integer'}
      } ]

    data =
      parameterizedField:
        intField: 5
        innerParameterized: 'foo'
      polymorphicField: -3
      floatField: 2.5

    system = typeSystem.init()
    system.register wrapperInterface
    system.register parameterizedType
    err = system.register outerType
    should.not.exist err

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize 'OuterType', data

    matched.should.match
      matched: true
      data: data
      typedata:
        type: 'OuterType'
        typeparameters: {}
        iscontainer: true
        fields:
          parameterizedField:
            type: 'ParameterizedType'
            typeparameters: {fieldParameter: 'String'}
            iscontainer: true
            fields:
              intField:
                type: 'Integer'
                iscontainer: false
              innerParameterized:
                type: 'String'
                iscontainer: false
          polymorphicField:
            type: 'Integer'
            iscontainer: false
          floatField:
            type: 'Float'
            iscontainer: false


  it 'should let a typeclass pass parameters to a interface which it extends', ->
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

    data =
      aField: 1
      bField: 2

    system = typeSystem.init()
    system.register outerInterfaceA
    system.register outerInterfaceB
    system.register innerInterface
    system.register aType

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize 'AType', data

    matched.should.match
      matched: true
      data: data
      typedata:
        type: 'AType'
        typeparameters: {}
        iscontainer: true
        fields:
          aField:
            type: 'Integer'
            iscontainer: false
          bField:
            type: 'Integer'
            iscontainer: false

  it 'should allow parameters to be passed through multiple levels of wrappers', ->

    mostOuterInterface = newinterface:
      name: 'MostOuterInterface'
      typeparameters: ['mostOuterParam']
      fields:
        interfaceField: 'mostOuterParam'

    middleInterface = newinterface:
      name: 'MiddleInterface'
      typeparameters: ['middleParam']
      extends: [{'MostOuterInterface': 'mostOuterParam': 'middleParam'}]

    innerInterface = newinterface:
      name: 'InnerInterface'
      typeparameters: ['innerParam']
      extends: [{'MiddleInterface': 'middleParam': 'innerParam'}]

    mostOuterType = newtype:
      name: 'MostOuterType'
      interfaces: [{'InnerInterface': innerParam: 'Integer'}]
      fields:
        outerWrappedField:
          'MiddleType':
            'middleParameter': 'String'
            'middleInterfaceParameter': 'Float'

    middleType = newtype:
      name: 'MiddleType'
      typeParameters: ['middleParameter', 'middleInterfaceParameter']
      fields:
        middleWrappedField:
          'InnerType':
            'innerParameter': 'middleParameter'
            'innerInterfaceParameter': 'middleInterfaceParameter'

    innerType = newtype:
      name: 'InnerType'
      interfaces: [{'InnerInterface': innerParam: 'innerInterfaceParameter'}]
      typeParameters: ['innerParameter', 'innerInterfaceParameter']
      fields:
        innerField: 'innerParameter'

    data =
      interfaceField: 5
      outerWrappedField:
        middleWrappedField:
          innerField: 'some string'
          interfaceField: 4.5

    system = typeSystem.init()
    system.register mostOuterInterface
    system.register middleInterface
    system.register innerInterface
    system.register mostOuterType
    system.register middleType
    system.register innerType

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize 'MostOuterType', data


    expected =
      matched: true
      data: data
      typedata:
        type: 'MostOuterType'
        typeparameters: {}
        iscontainer: true
        fields:
          interfaceField:
            type: 'Integer'
            iscontainer: false
          outerWrappedField:
            type: 'MiddleType'
            typeparameters: {middleParameter: 'String', middleInterfaceParameter: 'Float'}
            iscontainer: true
            fields:
              middleWrappedField:
                type: 'InnerType'
                typeparameters: {innerParameter: 'String', innerInterfaceParameter: 'Float'}
                iscontainer: true
                fields:
                  innerField:
                    type: 'String'
                    iscontainer: false
                  interfaceField:
                    type: 'Float'
                    iscontainer: false

    matched.should.match expected


  it "should properly store an interface's type parameters in the metadata when an interface is explicitly recognized", ->
    outerType = newtype:
      name: 'OuterType'
      fields:
        interfaceField:
          'AnInterface':
            firstParam: 'InnerType'
            secondParam: 'StoredInterface'

    anInterface = newinterface:
      name: 'AnInterface'
      typeparameters: ['firstParam', 'secondParam']
      fields:
        firstField: 'firstParam'
        secondField: 'secondParam'

    thingWithAnInterface = newtype:
      name: 'ThingWithAnInterface'
      interfaces: ['AnInterface']

    storedInterface = newinterface:
      name: 'StoredInterface',
      fields:
        aString: 'String'

    thingWithStoredInterface = newtype:
      name: 'ThingWithStoredInterface'
      interfaces: ['StoredInterface']

    innerType = newtype:
      name: 'InnerType'
      fields:
        anInteger: 'Integer'

    data =
      interfaceField:
        firstField:
          anInteger: 5
        secondField:
          aString: 'foo'

    system = typeSystem.init()
    system.register outerType
    system.register thingWithAnInterface
    system.register thingWithStoredInterface
    system.register anInterface
    system.register storedInterface
    system.register innerType

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize 'OuterType', data

    matched.should.match
      matched: true
      data: data
      typedata:
        type: 'OuterType'
        fields:
          interfaceField:
            type: 'ThingWithAnInterface'
            typeparameters: { firstParam: 'InnerType', secondParam: 'StoredInterface' }
            iscontainer: true
            fields:
              firstField:
                type: 'InnerType'
                iscontainer: true
                fields:
                  anInteger:
                    type: 'Integer'
              secondField:
                type: 'ThingWithStoredInterface'
                iscontainer: true
                fields:
                  aString:
                    type: 'String'


  it "should store the type parameters of a container type that's mixed in from an interface in the metadata", ->
    parameterizedType = newtype:
      name: 'ParameterizedType'
      typeparameters: ['aParam']
      fields:
        parameterizedField: 'aParam'

    parametricInterface = newinterface:
      name: 'ParametricInterface'
      fields:
        mixedInField:
          'ParameterizedType':
            aParam: 'Integer'

    aType = newtype:
      name: 'AType'
      interfaces: ['ParametricInterface']

    data =
      mixedInField:
        parameterizedField: 5

    system = typeSystem.init()
    system.register parameterizedType
    system.register parametricInterface
    system.register aType

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize 'AType', data

    matched.should.match
      matched: true
      data: data
      typedata:
        type: 'AType'
        iscontainer: true
        fields:
          mixedInField:
            type: 'ParameterizedType'
            typeparameters: {aParam: 'Integer'}
            iscontainer: true
            fields:
              parameterizedField:
                type: 'Integer'

  it.skip 'should let you pass a type parameter to a field which is also parametric', ->

    innerType = newtype:
      name: 'InnerType'
      typeparameters: ['innerParam']
      fields:
        innerField: 'innerParam'

    middleType = newtype:
      name: 'MiddleType'
      typeparameters: ['containingType', 'wrappedType']
      fields:
        middleField:
          containingType: 'wrappedType'

    outerType = newtype:
      name: 'OuterType'
      fields:
        outerField:
          'MiddleType':
            containingType: 'InnerType'
            wrappedType: 'Float'

    data =
      outerField:
        middleField:
          innerField: 1.5

    system = typeSystem.init()
    system.register innerType
    system.register middleType
    system.register outerType

    system.generateParsers()
    recognize = system.getRecognizer()

    debugger;
    matched = recognize 'OuterType', data

    matched.should.match
      matched: true
      data: data
      typedata:
        type: 'OuterType'
        iscontainer: true
        fields:
          outerField:
            type: 'MiddleType'
            typeparameters: { containingType: 'InnerType', wrappedType: 'Float'}
            fields:
              middleField:
                type: 'InnerType'
                iscontainer: true
                typeparameters: {innerParam: 'Float'}
                fields:
                  innerField:
                    type: 'Float'
