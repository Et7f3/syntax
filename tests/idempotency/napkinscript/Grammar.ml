module Grammar = struct
  type t =
    | OpenDescription (* open Belt *)
    | ModuleLongIdent (* Foo or Foo.Bar *)
    | Ternary (* condExpr ? trueExpr : falseExpr *)
    | Es6ArrowExpr
    | Jsx
    | JsxAttribute
    | JsxChild
    | ExprOperand
    | ExprUnary
    | ExprSetField
    | ExprBinaryAfterOp of Token.t
    | ExprBlock
    | ExprCall
    | ExprList
    | ExprArrayAccess
    | ExprArrayMutation
    | ExprIf
    | IfCondition | IfBranch | ElseBranch
    | TypeExpression
    | External
    | PatternMatching
    | PatternMatchCase
    | LetBinding
    | PatternList
    | PatternOcamlList
    | PatternRecord

    | TypeDef
    | TypeConstrName
    | TypeParams
    | TypeParam
    | PackageConstraint

    | TypeRepresentation

    | RecordDecl
    | ConstructorDeclaration
    | ParameterList
    | StringFieldDeclarations
    | FieldDeclarations
    | TypExprList
    | FunctorArgs
    | ModExprList
    | TypeParameters
    | RecordRows
    | RecordRowsStringKey
    | ArgumentList
    | Signature
    | Specification
    | Structure
    | Implementation
    | Attribute
    | TypeConstraint
    | Primitive
    | AtomicTypExpr
    | ListExpr
    | JsFfiImport

  let toString = function
    | OpenDescription -> "an open description"
    | ModuleLongIdent -> "a module identifier"
    | Ternary -> "a ternary expression"
    | Es6ArrowExpr -> "an es6 arrow function"
    | Jsx -> "a jsx expression"
    | JsxAttribute -> "a jsx attribute"
    | ExprOperand -> "a basic expression"
    | ExprUnary -> "a unary expression"
    | ExprBinaryAfterOp op -> "an expression after the operator \"" ^ Token.toString op  ^ "\""
    | ExprIf -> "an if expression"
    | IfCondition -> "the condition of an if expression"
    | IfBranch -> "the true-branch of an if expression"
    | ElseBranch -> "the else-branch of an if expression"
    | TypeExpression -> "a type"
    | External -> "an external"
    | PatternMatching -> "the cases of a pattern match"
    | ExprBlock -> "a block with expressions"
    | ExprSetField -> "a record field mutation"
    | ExprCall -> "a function application"
    | ExprArrayAccess -> "an array access expression"
    | ExprArrayMutation -> "an array mutation"
    | LetBinding -> "a let binding"
    | TypeDef -> "a type definition"
    | TypeParams -> "type parameters"
    | TypeParam -> "a type parameter"
    | TypeConstrName -> "a type-constructor name"
    | TypeRepresentation -> "a type representation"
    | RecordDecl -> "a record declaration"
    | PatternMatchCase -> "a pattern match case"
    | ConstructorDeclaration -> "a constructor declaration"
    | ExprList -> "multiple expressions"
    | PatternList -> "multiple patterns"
    | PatternOcamlList -> "a list pattern"
    | PatternRecord -> "a record pattern"
    | ParameterList -> "parameters"
    | StringFieldDeclarations -> "string field declarations"
    | FieldDeclarations -> "field declarations"
    | TypExprList -> "list of types"
    | FunctorArgs -> "functor arguments"
    | ModExprList -> "list of module expressions"
    | TypeParameters -> "list of type parameters"
    | RecordRows -> "rows of a record"
    | RecordRowsStringKey -> "rows of a record with string keys"
    | ArgumentList -> "arguments"
    | Signature -> "signature"
    | Specification -> "specification"
    | Structure -> "structure"
    | Implementation -> "implementation"
    | Attribute -> "an attribute"
    | TypeConstraint -> "constraints on a type"
    | Primitive -> "an external primitive"
    | AtomicTypExpr -> "a type"
    | ListExpr -> "an ocaml list expr"
    | PackageConstraint -> "a package constraint"
    | JsFfiImport -> "js ffi import"
    | JsxChild -> "jsx child"

  let isSignatureItemStart = function
    | Token.At
    | Let
    | Typ
    | External
    | Exception
    | Open
    | Include
    | Module
    | AtAt
    | PercentPercent -> true
    | _ -> false

  let isAtomicPatternStart = function
    | Token.Int _ | String _ | Character _
    | Lparen | Lbracket | Lbrace
    | Underscore
    | Lident _ | Uident _ | List
    | Exception | Lazy
    | Percent -> true
    | _ -> false

  let isAtomicExprStart = function
    | Token.True | False
    | Int _ | String _ | Float _ | Character _
    | Backtick
    | Uident _ | Lident _
    | Lparen
    | List
    | Lbracket
    | Lbrace
    | LessThan
    | Module
    | Percent -> true
    | _ -> false

  let isAtomicTypExprStart = function
    | Token.SingleQuote | Underscore
    | Lparen | Lbrace
    | Uident _ | Lident _ | List
    | Percent -> true
    | _ -> false

  let isExprStart = function
    | Token.True | False
    | Int _ | String _ | Float _ | Character _ | Backtick
    | Uident _ | Lident _
    | Lparen | List | Module | Lbracket | Lbrace
    | LessThan
    | Minus | MinusDot | Plus | PlusDot | Bang | Band
    | Percent | At
    | If | Switch | While | For | Assert | Lazy | Try -> true
    | _ -> false

  let isJsxAttributeStart = function
    | Token.Lident _ | Question -> true
    | _ -> false

 let isStructureItemStart = function
    | Token.Open
    | Let
    | Typ
    | External | Import | Export
    | Exception
    | Include
    | Module
    | AtAt
    | PercentPercent
    | At -> true
    | t when isExprStart t -> true
    | _ -> false

  let isPatternStart = function
    | Token.Int _ | String _ | Character _ | True | False
    | Lparen | Lbracket | Lbrace | List
    | Underscore
    | Lident _ | Uident _
    | Exception | Lazy | Percent | Module
    | At -> true
    | _ -> false

  let isParameterStart = function
    | Token.Typ | Tilde | Dot -> true
    | token when isPatternStart token -> true
    | _ -> false

  (* TODO: overparse Uident ? *)
  let isStringFieldDeclStart = function
    | Token.String _ | At -> true
    | _ -> false

  (* TODO: overparse Uident ? *)
  let isFieldDeclStart = function
    | Token.At | Mutable | Lident _  -> true
    (* recovery, TODO: this is not ideal… *)
    | Uident _ -> true
    | t when Token.isKeyword t -> true
    | _ -> false

  let isRecordDeclStart = function
    | Token.At
    | Mutable
    | Lident _ -> true
    | _ -> false

  let isTypExprStart = function
    | Token.At
    | SingleQuote
    | Underscore
    | Lparen
    | Uident _ | Lident _ | List
    | Module
    | Percent
    | Lbrace -> true
    | _ -> false

  let isTypeParameterStart = function
    | Token.Tilde | Dot -> true
    | token when isTypExprStart token -> true
    | _ -> false

  let isTypeParamStart = function
    | Token.Plus | Minus | SingleQuote | Underscore -> true
    | _ -> false

  let isFunctorArgStart = function
    | Token.At | Uident _ | Underscore
    | Percent
    | Lbrace
    | Lparen -> true
    | _ -> false

  let isModExprStart = function
    | Token.At | Percent
    | Uident _ | Lbrace | Lparen -> true
    | _ -> false

  let isRecordRowStart = function
    | Token.DotDotDot -> true
    | Token.Uident _ | Lident _ -> true
    (* TODO *)
    | t when Token.isKeyword t -> true
    | _ -> false

  let isRecordRowStringKeyStart = function
    | Token.String _ -> true
    | _ -> false

  let isArgumentStart = function
    | Token.Tilde | Dot | Underscore -> true
    | t when isExprStart t -> true
    | _ -> false

  let isPatternMatchStart = function
    | Token.Bar -> true
    | t when isPatternStart t -> true
    | _ -> false

  let isPatternOcamlListStart = function
    | Token.DotDotDot -> true
    | t when isPatternStart t -> true
    | _ -> false

  let isPatternRecordItemStart = function
    | Token.DotDotDot | Uident _ | Lident _ | Underscore -> true
    | _ -> false

  let isAttributeStart = function
    | Token.At -> true
    | _ -> false

  let isJsFfiImportStart = function
    | Token.Lident _ | At -> true
    | _ -> false

  let isJsxChildStart = isAtomicExprStart

  let isBlockExprStart = function
    | Token.At | Percent | Minus | MinusDot | Plus | PlusDot | Bang | Band
    | True | False | Int _ | String _ | Character _ | Lident _ | Uident _
    | Lparen | List | Lbracket | Lbrace | Forwardslash | Assert
    | Lazy | If | For | While | Switch | Open | Module | Exception | Let
    | LessThan | Backtick | Try | Underscore -> true
    | _ -> false

  let isListElement grammar token =
    match grammar with
    | ExprList -> token = Token.DotDotDot || isExprStart token
    | ListExpr -> token = DotDotDot || isExprStart token
    | PatternList -> token = DotDotDot || isPatternStart token
    | ParameterList -> isParameterStart token
    | StringFieldDeclarations -> isStringFieldDeclStart token
    | FieldDeclarations -> isFieldDeclStart token
    | RecordDecl -> isRecordDeclStart token
    | TypExprList -> isTypExprStart token || token = Token.LessThan
    | TypeParams -> isTypeParamStart token
    | FunctorArgs -> isFunctorArgStart token
    | ModExprList -> isModExprStart token
    | TypeParameters -> isTypeParameterStart token
    | RecordRows -> isRecordRowStart token
    | RecordRowsStringKey -> isRecordRowStringKeyStart token
    | ArgumentList -> isArgumentStart token
    | Signature | Specification -> isSignatureItemStart token
    | Structure | Implementation -> isStructureItemStart token
    | PatternMatching -> isPatternMatchStart token
    | PatternOcamlList -> isPatternOcamlListStart token
    | PatternRecord -> isPatternRecordItemStart token
    | Attribute -> isAttributeStart token
    | TypeConstraint -> token = Constraint
    | PackageConstraint -> token = And
    | ConstructorDeclaration -> token = Bar
    | Primitive -> begin match token with Token.String _ -> true | _ -> false end
    | JsxAttribute -> isJsxAttributeStart token
    | JsFfiImport -> isJsFfiImportStart token
    | _ -> false

  let isListTerminator grammar token =
    token = Token.Eof ||
    (match grammar with
    | ExprList  ->
        token = Token.Rparen || token = Forwardslash || token = Rbracket
    | ListExpr ->
        token = Token.Rparen
    | ArgumentList -> token = Token.Rparen
    | TypExprList ->
        token = Rparen || token = Forwardslash || token = GreaterThan
        || token = Equal
    | ModExprList ->
        token = Rparen
    | PatternList | PatternOcamlList | PatternRecord ->
        token = Forwardslash || token = Rbracket || token = Rparen
        || token = EqualGreater (* pattern matching =>*)
        || token = In (* for expressions *)
        || (* let {x} = foo *) token = Equal
    | ExprBlock -> token = Rbrace
    | Structure | Signature -> token = Rbrace
    | TypeParams -> token = Rparen
    | ParameterList -> token = EqualGreater || token = Lbrace
    | Attribute -> token <> At
    | TypeConstraint -> token <> Constraint
    | PackageConstraint -> token <> And
    | ConstructorDeclaration -> token <> Bar
    | Primitive -> isStructureItemStart token || token = Semicolon
    | JsxAttribute -> token = Forwardslash || token = GreaterThan
    | JsFfiImport -> token = Rbrace
    | StringFieldDeclarations -> token = Rbrace
    | _ -> false
    )

  let isPartOfList grammar token =
    isListElement grammar token || isListTerminator grammar token
end
