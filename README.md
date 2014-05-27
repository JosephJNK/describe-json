describe-json
=======

Algebraic data types and pattern matching for JSON

# Overview

describe-json is a tool for input validation for APIs which consume JSON, and for parsing JSON data structures and domain specific languages. Its declarative syntax makes the structure of expected input explicit, and its pattern matching functionality makes parsing input simpler and less error prone. It is currently under development and in beta. Some features may not be complete.

# Features

All input into describe-json is JSON, with the exception of pattern matching, which takes functions as well.

## Types

A type is described with the following syntax

```coffeescript

newtype:
  name: 'ThreeFields'
  fields:
    intField: 'Integer'
    stringField: 'String'
    objectField: 'Object'

```
This describes a type named "ThreeFields", which has the fields "intField", containing an Integer, "stringField", containing a string, and "objectField", containing a JSON object whose structure is opaque.

Types may contain other types:

```coffeescript
newtype:
  name: 'InnerType'
  fields:
    string: 'String'

newtype:
  name: 'OuterType'
  fields:
    inner: 'InnerType'
    int: 'Integer'
```

## Interfaces

An interface specifies fields with given types that must exist on any type which is a member of the interface. Their syntax is similar to that of types:

```coffeescript
newinterface:
  name: 'SimpleInterface'
  fields:
    numberField: 'Number'
    
# An interface doesn't have to have any fields
newinterface
  name: 'VerySimpleInterface'
```
A type specifies that it extends an interface with the 'interfaces' field. A type that does so will have the fields of said interface mixed in to its definition.

```coffeescript
newtype:
  name: 'IHaveTwoNumberFields'
  interfaces: ['SimpleInterface', 'VerySimpleInterface']
  fields:
    myOwnNumberField: 'Number'
```
Interfaces may also belong to interfaces:

```coffeescript
newinterface:
  name: 'StringAndNumberField'
  interfaces: ['SimpleInterface']
  fields:
    stringField: 'String'
```
A type or interface which has a collision between fields mixed in by the interfaces it implements will cause an error to be reported when describe-json is initialized. Later development work will try to refine this behavior, to only throw an error if the types are incompatible (i.e. if neither is a subset of the other.) Circular dependencies in interfaces will result in an error being reported at initialization.

Types can use interfaces as the type of one of their fields:
```coffeescript
newtype:
  name: 'BasicPolymorphicType'
  fields:
    objectContainingNumberField: 'SimpleInterface'
```

## Type Parameters

Type parameters are currently under development and will be enabled soon.

```coffeescript
newtype:
  name: 'ParametricallyPolymorphicType'
  typeparameters: ['fieldParameter']
  fields:
    polymorphicField: 'fieldParameter'
    
newtype:
  name: 'NumberType'
  fields:
    parameterizedField:
      'ParametricallyPolymorphicType':
        fieldParameter: 'Number'
        
newtype:
  name: 'StringType'
  fields:
    parameterizedField:
      'ParametricallyPolymorphicType':
        fieldParameter: 'String'
```
'NumberType' describes an object with a field called 'parameterizedField', which itself contains a field called 'polymorphicField' containing a Number. 'StringType' has the same structure, but with 'polymorphicField' containing a String.

Support for type parameters on interfaces, and the use of an interface as a type parameter are being added as well.

## Initialization

Initialization is currently a little clunky, and will eventually be streamlined.

```coffeescript
dispatcher = require '../src/dispatcher'
typeSystem = require '../src/typeSystem'

system = typeSystem.init()
system.register newtype:
  name: 'AType'
  fields:
    floatField: 'Float'
    
dispatch = dispatcher.init system
```

## Pattern Matching

Pattern matching is currently only supported on the names of types and interfaces. Future development will focus on specifying field properties and type parameters in patterns.

```coffeescript

aTypeMatched = ({floatField}) -> console.log "The field #{floatField} was received!"

dispatch {floatField: 1.5}, [AType: aTypeMatched] # Will print the above

dispatch {floatField: 'foo'}, [
  {AType: aTypeMatched},
  {otherwise: -> console.log 'No matches'}
]
```
Patterns occurring earlier in the dispatch list take precedence over patterns occuring later. The 'otherwise' pattern is matched if no earlier patterns match.

# Current Development

describe-json is currently under heavy development and is not recommended for use at this time. Implementation of type parameters is the current top priority, followed by more powerful pattern support and increased static checking.
