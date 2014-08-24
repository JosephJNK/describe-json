{destructureSingleKey, beginsWithUpperCase, beginsWithLowerCase, isString} = require './utilities'

validateTypeDeclarations = (typeDeclarations, interfaceDeclarations, interfaceMembers) ->
  for typeName, typeDeclaration of typeDeclarations
    for fieldName, fieldDeclaration of typeDeclaration.fields
      continue if isString fieldDeclaration
      [fieldType, fieldTypeParameters] = destructureSingleKey fieldDeclaration
      if beginsWithLowerCase fieldType
        #TODO: make an error here if this isn't declared as a type parameter
        continue
      for parameterName, parameterValue of fieldTypeParameters
        err = validateParameter fieldType, parameterName, parameterValue, typeDeclarations, interfaceDeclarations, interfaceMembers
        continue unless err
        paramError = {}
        paramError[parameterName] = parameterValue
        return parameterConstraint:
          parameter: paramError
          containingType: typeName
  null

validateInterfaceDeclarations = (interfaceDeclarations, interfaceMembers) ->
  null

validateParameter = (baseType, paramName, paramType, typeDeclarations, interfaceDeclarations, interfaceMembers) ->
  baseParamDeclarations = typeDeclarations[baseType]?.typeparameters or interfaceDeclarations[baseType].typeparameters
  for baseParamDeclaration in baseParamDeclarations
    debugger
    return if isString(baseParamDeclaration) and baseParamDeclaration == paramName
    continue if isString(baseParamDeclaration) and baseParamDeclaration != paramName
    [declarationParamName, paramConstraints] = destructureSingleKey baseParamDeclaration
    continue if declarationParamName != paramName
    return validateParameterConstraints paramType, paramConstraints, typeDeclarations, interfaceDeclarations, interfaceMembers

validateParameterConstraints = (parameterType, parameterConstraints, typeDeclarations, interfaceDeclarations, interfaceMembers) ->
  return if isString(parameterConstraints) and parameterType == parameterConstraints
  return true if isString(parameterConstraints) and parameterType != parameterConstraints
  #TODO add recursive checks here

#If the type registry is available at this point it would make this less verbose
module.exports = (interfaceMembers, typeDeclarations, interfaceDeclarations) ->
  typeDeclarationError = validateTypeDeclarations typeDeclarations, interfaceDeclarations, interfaceMembers
  return typeDeclarationError if typeDeclarationError
  interfaceDeclarationError = validateInterfaceDeclarations interfaceDeclarations, interfaceMembers
  return interfaceDeclarationError

