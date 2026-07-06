"
A visitor that extracts features from a Fortran JSON AST.

To use:
```
extractor := FortranFeatureExtractor new.
extractor visitProgramFile: (NeoJSONReader fromString: '/path/to/tmpJsonImport/src/xyz.json' asFileReference contents).
extractor features.
```
"
Class {
	#name : 'FortranFeatureExtractor',
	#superclass : 'FortranAbstractJsonVisitor',
	#instVars : [
		'features',
		'f77sourcefile'
	],
	#category : 'FeatureExtractor-Visitor',
	#package : 'FeatureExtractor',
	#tag : 'Visitor'
}

{ #category : 'private' }
FortranFeatureExtractor >> controlFlowFeatureNamed: aName atLine: aLineNumber [
	^ FFEControFlowStatement new
		controFlowStatementName: aName;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> declarationFeatureNamed: aName ofType: aType atLine: aLineNumber [
	^ FFEDeclaration new
		declaredName: aName;
		declaredType: aType asUppercase;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> expressionFeatureNamed: aSymbol atLine: aLineNumber [
	^ FFEExpression new
		operator: aSymbol;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'accessing' }
FortranFeatureExtractor >> features [
	^ features
]

{ #category : 'initialization' }
FortranFeatureExtractor >> initialize [
	super initialize.
	features := OrderedCollection new.
	f77sourcefile := ''
]

{ #category : 'private' }
FortranFeatureExtractor >> invocationFeatureFrom: data [
	"data = #(spanResult functionResult argumentsResult)
	 spanResult     = {startLine@startCol, endLine@endCol}
	 functionResult = {span, nameString}  (from visitFunctionAsValue:)"
	^ FFEInvocationFeature new
		lineNumber: data first first x;
		filename: f77sourcefile;
		invokedName: data second second;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> ioStatementFeatureNamed: aType atLine: aLineNumber [
	^ FFEIOStatement new
		ioStatementType: aType;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> operatorSymbolFor: aRawTag [
	^ (Dictionary newFromPairs: {
		'lt'. '.LT.'. 'lte'. '.LE.'. 'eq'. '.EQ.'. 'ne'. '.NE.'. 'gt'. '.GT.'. 'gte'. '.GE.'.
		'and'. '.AND.'. 'or'. '.OR.'. 'not'. '.NOT.'.
		'exponentiation'. '**'. 'multiplication'. '*'. 'division'. '/'.
		'subtraction'. '-'. 'addition'. '+'. 'minus'. '-'
	}) at: aRawTag ifAbsent: [ nil ]
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitBinary: aBinaryExpressionNode [
	| opTag data symbol |
	opTag := (aBinaryExpressionNode at: 'op') at: 'tag'.
	data := super visitBinary: aBinaryExpressionNode.
	symbol := self operatorSymbolFor: opTag.
	symbol ifNotNil: [
		features add: (self expressionFeatureNamed: symbol atLine: data first first x) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitCallStatement: aCallNode [
	"Subroutine calls: CALL subName(...)"
	| data |
	data := super visitCallStatement: aCallNode.
	features add: (self invocationFeatureFrom: data).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitCloseStatement: aCloseStatementNode [
	| data |
	data := super visitCloseStatement: aCloseStatementNode.
	features add: (self ioStatementFeatureNamed: 'CLOSE' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitConditions: aConditionList [
	"index 1 is the IF branch (already recorded in visitIf:); index 2+ are ELSE IF"
	aConditionList doWithIndex: [ :aCondition :i |
		i > 1 ifTrue: [
			features add: (self controlFlowFeatureNamed: 'ELSE IF'
				atLine: (self visitSpan: (aCondition first at: #span)) first x) ] ].
	^ super visitConditions: aConditionList
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitContinueStatement: aContinueStatementNode [
	| data |
	data := super visitContinueStatement: aContinueStatementNode.
	features add: (self controlFlowFeatureNamed: 'CONTINUE' atLine: data first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitDeclarationStatement: aDeclarationStatementNode [
	"CHARACTER/LOGICAL/INTEGER/REAL/... -- one node type, differentiated by base_type"
	| data baseType declarators |
	data := super visitDeclarationStatement: aDeclarationStatementNode.
	baseType := data second second.
	declarators := data fourth second.
	declarators do: [ :declarator |
		features add: (self declarationFeatureNamed: declarator fifth second
			ofType: baseType atLine: declarator first first x) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitDo: aDoNode [
	| data |
	data := super visitDo: aDoNode.
	features add: (self controlFlowFeatureNamed: 'DO' atLine: data first first x).
	features add: (self controlFlowFeatureNamed: 'END DO' atLine: data first second x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitExternalStatement: anExternalStatementNode [
	| data vars |
	data := super visitExternalStatement: anExternalStatementNode.
	vars := data second.
	vars do: [ :aVar |
		features add: (self declarationFeatureNamed: aVar second
			ofType: 'EXTERNAL' atLine: aVar first first x) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitFunction_call: aFunctionCallNode [
	"Function invocations used as expressions: result = funcName(...)"
	| data |
	data := super visitFunction_call: aFunctionCallNode.
	features add: (self invocationFeatureFrom: data).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitGotoStatement: aGotoStatementNode [
	| data |
	data := super visitGotoStatement: aGotoStatementNode.
	features add: (self controlFlowFeatureNamed: 'GOTO' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitGoto_computedStatement: aGotoComputedStatementNode [
	| data |
	data := super visitGoto_computedStatement: aGotoComputedStatementNode.
	features add: (self controlFlowFeatureNamed: 'GOTO' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitIf: anIfNode [
	"Block IF...THEN...[ELSE IF]...[ELSE]...END IF"
	| data |
	data := super visitIf: anIfNode.
	features add: (self controlFlowFeatureNamed: 'IF' atLine: data first first x).
	(anIfNode at: #blocks ifAbsent: [ nil ]) ifNotNil: [ :blocks |
		blocks ifNotEmpty: [
			features add: (self controlFlowFeatureNamed: 'ELSE'
				atLine: (self visitSpan: (blocks first at: #span)) first x - 1) ] ].
	features add: (self controlFlowFeatureNamed: 'END IF' atLine: data first second x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitIf_arithmeticStatement: anIfArithmeticStatement [
	| data |
	data := super visitIf_arithmeticStatement: anIfArithmeticStatement.
	features add: (self controlFlowFeatureNamed: 'IF' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitIf_logicalStatement: anIfNode [
	| data |
	data := super visitIf_logicalStatement: anIfNode.
	features add: (self controlFlowFeatureNamed: 'IF' atLine: data first first x).
	^ data
]

{ #category : 'visiting prog-unit' }
FortranFeatureExtractor >> visitMiFilename: aString [
	f77sourcefile := aString
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitOpenStatement: anOpenStatement [
	| data |
	data := super visitOpenStatement: anOpenStatement.
	features add: (self ioStatementFeatureNamed: 'OPEN' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitParameterStatement: aParameterStatementNode [
	| data declarators |
	data := super visitParameterStatement: aParameterStatementNode.
	declarators := data second second.
	declarators do: [ :declarator |
		features add: (self declarationFeatureNamed: declarator fifth second
			ofType: 'PARAMETER' atLine: declarator first first x) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitPrintStatement: aPrintStatementNode [
	| data |
	data := super visitPrintStatement: aPrintStatementNode.
	features add: (self ioStatementFeatureNamed: 'PRINT' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitRead2Statement: aStatementNode [
	| data |
	data := super visitRead2Statement: aStatementNode.
	features add: (self ioStatementFeatureNamed: 'READ' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitReadStatement: aReadStatementNode [
	| data |
	data := super visitReadStatement: aReadStatementNode.
	features add: (self ioStatementFeatureNamed: 'READ' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitUnary: aUnaryNode [
	| opTag data symbol |
	opTag := (aUnaryNode at: 'op') at: 'tag'.
	data := super visitUnary: aUnaryNode.
	symbol := self operatorSymbolFor: opTag.
	symbol ifNotNil: [
		features add: (self expressionFeatureNamed: symbol atLine: data first first x) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitWriteStatement: aWriteStatementNode [
	| data |
	data := super visitWriteStatement: aWriteStatementNode.
	features add: (self ioStatementFeatureNamed: 'WRITE' atLine: data first first x).
	^ data
]
