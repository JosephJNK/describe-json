recognizer = require '../src/recognizer'
typeSystem = require '../src/typeSystem'
{inspect} = require 'util'

describe 'typeclasses', ->

  it 'should allow for basic polymorphism', ->

    outerType = newtype:
      name: 'OuterType'
      fields:
        inner: 'InnerTypeclass'

    innerTypeA = newtype:
      name: 'InnerTypeA'
      typeclasses: ['InnerTypeclass']
      fields:
        str: 'String'

    innerTypeB = newtype:
      name: 'InnerTypeB'
      typeclasses: ['InnerTypeclass']
      fields:
        int: 'Integer'

    innerTypeclass = newtypeclass:
      name: 'InnerTypeclass'

    system = typeSystem.init()

    system.register outerType
    system.register innerTypeA
    system.register innerTypeB
    system.register innerTypeclass

    system.init()

    recognize = recognizer.init system

    matchedA = recognize 'OuterType', inner: {str: 'foo'}

    matchedA.matched.should.eql true
    matchedA.data.should.eql inner: {str: 'foo'}
    matchedA.typedata.type.should.eql 'OuterType'
    matchedA.typedata.iscontainer.should.eql true
    matchedA.typedata.fields.inner.type.should.eql 'InnerTypeA'
    matchedA.typedata.fields.inner.iscontainer.should.eql true
    matchedA.typedata.fields.inner.fields.str.type.should.eql 'String'
    matchedA.typedata.fields.inner.fields.str.iscontainer.should.eql false

    matchedB = recognize 'OuterType', inner: {int: 1}

    matchedB.matched.should.eql true
    matchedB.data.should.eql inner: {int: 1}
    matchedB.typedata.type.should.eql 'OuterType'
    matchedB.typedata.iscontainer.should.eql true
    matchedB.typedata.fields.inner.type.should.eql 'InnerTypeB'
    matchedB.typedata.fields.inner.iscontainer.should.eql true
    matchedB.typedata.fields.inner.fields.int.type.should.eql 'Integer'
    matchedB.typedata.fields.inner.fields.int.iscontainer.should.eql false

    recognize('OuterType', inner: {foo: 'foo'}).matched.should.eql false
    recognize('OuterType', inner: {int: {}}).matched.should.eql false

  it 'should mix in fields', ->

    memberType =
      newtype:
        name: "MemberType"
        typeclasses: ["TypeclassWithField"]
        fields:
          ownField: "Integer"

    typeclass =
      newtypeclass:
        name: "TypeclassWithField"
        fields:
          classField: "String"

    system = typeSystem.init()
    system.register memberType
    system.register typeclass
    recognize = recognizer.init system

    matched = recognize "MemberType", {ownField: 0, classField: 'foo'}

    matched.matched.should.eql true
    matched.data.should.eql {ownField: 0, classField: 'foo'}
    matched.typedata.type.should.eql 'MemberType'
    matched.typedata.iscontainer.should.eql true
    matched.typedata.fields.ownField.type.should.eql 'Integer'
    matched.typedata.fields.ownField.iscontainer.should.eql false
    matched.typedata.fields.classField.type.should.eql 'String'
    matched.typedata.fields.classField.iscontainer.should.eql false
