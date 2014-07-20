typeSystem = require '../src/typeSystem'

describe 'interfaces', ->

  it 'should allow for basic polymorphism', ->

    outerType = newtype:
      name: 'OuterType'
      fields:
        inner: 'InnerInterface'

    innerTypeA = newtype:
      name: 'InnerTypeA'
      interfaces: ['InnerInterface']
      fields:
        str: 'String'

    innerTypeB = newtype:
      name: 'InnerTypeB'
      interfaces: ['InnerInterface']
      fields:
        int: 'Integer'

    innerInterface = newinterface:
      name: 'InnerInterface'

    system = typeSystem.init()

    system.register outerType
    system.register innerTypeA
    system.register innerTypeB
    system.register innerInterface

    system.generateParsers()
    recognize = system.getRecognizer()

    matchedA = recognize 'OuterType', inner: {str: 'foo'}

    matchedA.should.match
      matched: true
      data: inner: str: 'foo'
      typedata:
        type: 'OuterType'
        iscontainer: true
        fields:
          inner:
            type: 'InnerTypeA'
            iscontainer: true
            fields:
              str:
                type: 'String'
                iscontainer: false

    matchedB = recognize 'OuterType', inner: {int: 1}

    matchedB.should.match
      matched: true
      data: inner: int: 1
      typedata:
        type: 'OuterType'
        iscontainer: true
        fields:
          inner:
            type: 'InnerTypeB'
            iscontainer: true
            fields:
              int:
                type: 'Integer'
                iscontainer: false

    recognize('OuterType', inner: {foo: 'foo'}).matched.should.eql false
    recognize('OuterType', inner: {int: {}}).matched.should.eql false

  it 'should mix in fields', ->

    memberType =
      newtype:
        name: "MemberType"
        interfaces: ["InterfaceWithField"]
        fields:
          ownField: "Integer"

    interFace =
      newinterface:
        name: "InterfaceWithField"
        fields:
          classField: "String"

    system = typeSystem.init()
    system.register memberType
    system.register interFace

    system.generateParsers()
    recognize = system.getRecognizer()

    matched = recognize "MemberType", {ownField: 0, classField: 'foo'}

    matched.should.match
    matched: true
    data: ownField: 0, classField: 'foo'
    typedata:
      type: 'MemberType'
      iscontainer: true
      fields:
        ownField:
          type: 'Integer'
          iscontainer: false
        classField:
          type: 'String'
          iscontainer: false
