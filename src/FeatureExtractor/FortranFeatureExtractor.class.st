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
		'f77sourcefile',
		'isAssignmentTarget',
		'isDerefSubscripted'
	],
	#category : 'FeatureExtractor-Visitor',
	#package : 'FeatureExtractor',
	#tag : 'Visitor'
}

{ #category : 'private' }
FortranFeatureExtractor class >> collectStringLeaves: aStructure [
	aStructure isString ifTrue: [^ OrderedCollection with: aStructure].
	(aStructure isKindOf: Collection) ifFalse: [^ OrderedCollection new].
	^ aStructure inject: OrderedCollection new into: [:acc :each | acc addAll: (self collectStringLeaves: each); yourself]
]

{ #category : 'private' }
FortranFeatureExtractor class >> csvValueOf: aValue named: fieldName [
	aValue ifNil: [^ ''].
	fieldName = #arguments ifTrue: [^ self flattenArguments: aValue].
	^ aValue asString
]

{ #category : 'batch' }
FortranFeatureExtractor class >> extractFeaturesFromJsonFilesIn: aFolderPathString [
	"Run the feature extractor over every .json file in aFolderPathString, write the
	 combined results as a wide, analysis-ready 'features.csv' in that same folder
	 (opens directly in Excel), and answer the sorted OrderedCollection of features."

	| folder allFeatures extraFields header |
	folder := aFolderPathString asFileReference.
	allFeatures := OrderedCollection new.
	folder files select: [:f | f extension = 'json'] thenDo: [:jsonFile |
		| visitor json |
		json := NeoJSONReader fromString: jsonFile contents.
		visitor := self new.
		visitor visitProgramFile: json.
		allFeatures addAll: visitor features].
	allFeatures := allFeatures asSortedCollection: [:a :b |
		a filename = b filename
			ifTrue: [a lineNumber <= b lineNumber]
			ifFalse: [a filename <= b filename]].

	extraFields := (FFEAbstractFeature allSubclasses gather: [:c | c instVarNames]) asSet asArray sorted.

	header := #('class' 'sourceFile' 'filename' 'lineNumber') , extraFields.
	(folder / 'features.csv') writeStreamDo: [:stream |
		| writer |
		writer := NeoCSVWriter on: stream.
		writer nextPut: header.
		allFeatures do: [:feature |
			| row |
			row := OrderedCollection new.
			row
				add: feature class name;
				add: feature filename asFileReference basename;
				add: feature filename;
				add: feature lineNumber.
			extraFields do: [:fieldName |
				row add: ((feature class instVarNames includes: fieldName)
					ifTrue: [self csvValueOf: (feature instVarNamed: fieldName) named: fieldName]
					ifFalse: [''])].
			writer nextPut: row asArray]].

	^ allFeatures
]

{ #category : 'private' }
FortranFeatureExtractor class >> flattenArguments: anArgumentsArray [
	"anArgumentsArray is a collection of entries shaped like {span. {span. value}},
	 value recursively either a String leaf or another such nested structure.
	 Answer a readable comma-joined string, e.g. 'lib, 1'."

	| perArgumentStrings |
	perArgumentStrings := (anArgumentsArray collect: [:entry |
		| leaves |
		leaves := self collectStringLeaves: entry.
		leaves isEmpty ifTrue: [''] ifFalse: [leaves fold: [:a :b | a, '.', b]]])
		reject: [:s | s isEmpty].
	^ perArgumentStrings isEmpty ifTrue: [''] ifFalse: [perArgumentStrings fold: [:a :b | a, ', ', b]]
]

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

{ #category : 'private' }
FortranFeatureExtractor >> getSizeFeatureFrom: derefData index: anIndexOrNil accessKind: aSymbol [
	^ FFEESOPEMemberAccess new
		baseName: derefData second second;
		memberName: derefData third second;
		index: anIndexOrNil;
		accessKind: aSymbol;
		lineNumber: derefData first first x;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> importFeatureFrom: anArgument atLine: aLineNumber [
	| dotIndex |
	dotIndex := anArgument lastIndexOf: $..
	^ FFEImportStatement new
		importName: (anArgument copyFrom: 1 to: dotIndex - 1);
		importExtension: (anArgument copyFrom: dotIndex to: anArgument size);
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> indexStringFrom: indicesArray [
	| val |
	indicesArray isEmpty ifTrue: [ ^ nil ].
	val := indicesArray first second second.
	^ val isString ifTrue: [ val ] ifFalse: [ nil ]
]

{ #category : 'initialization' }
FortranFeatureExtractor >> initialize [
	super initialize.
	features := OrderedCollection new.
	f77sourcefile := ''.
	isAssignmentTarget := false.
	isDerefSubscripted := false
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
FortranFeatureExtractor >> obsoleteCallNames [
	^ #('oooeta' 'actstr' 'desstr')
]

{ #category : 'private' }
FortranFeatureExtractor >> obsoleteEsopeCommandNames [
	^ #('segact' 'segdes')
]

{ #category : 'private' }
FortranFeatureExtractor >> obsoleteFunctionFeatureNamed: aName atLine: aLineNumber [
	^ FFEObsoleteFunction new
		obsoleteFunctionName: aName;
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

{ #category : 'private' }
FortranFeatureExtractor >> procedureFeatureNamed: aName ofType: aType atLine: aLineNumber [
	^ FFEProcedureDefinition new
		procedureName: aName;
		procedureType: aType;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> segmentFeatureFrom: anArgument atLine: aLineNumber [
	^ FFESegment new
		segmentName: 'pointeur';
		segmentType: anArgument;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> segmentFunctionCallFeatureFrom: data [
	^ FFESegmentFunctionCall new
		targetName: data second second;
		arguments: data third;
		lineNumber: data first first x;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> segmentFunctionCallNames [
	^ #('mypnt')
]

{ #category : 'private' }
FortranFeatureExtractor >> segmentInstructionFeatureNamed: aName atLine: aLineNumber [
	^ FFESegmentInstruction new
		invokedSegmentFunctionName: aName;
		lineNumber: aLineNumber;
		filename: f77sourcefile;
		yourself
]

{ #category : 'private' }
FortranFeatureExtractor >> segmentInstructionNames [
	^ #('segini' 'segsup' 'segdes' 'segact' 'segadj')
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
	| data name |
	data := super visitCallStatement: aCallNode.
	features add: (self invocationFeatureFrom: data).
	name := data second second.
	(self obsoleteCallNames includes: name asLowercase) ifTrue: [
		features add: (self obsoleteFunctionFeatureNamed: name atLine: data first first x) ].
	(self segmentFunctionCallNames includes: name asLowercase) ifTrue: [
		features add: (self segmentFunctionCallFeatureFrom: data) ].
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
FortranFeatureExtractor >> visitComment: aCommentNode [
	| data command |
	data := super visitComment: aCommentNode.
	(self isEsopeComment: data second) ifTrue: [
		command := self esopeCommand: data second.
		(command size = 2 and: [ command first asLowercase = 'include' ]) ifTrue: [
			features add: (self importFeatureFrom: command second atLine: data first first x) ].
		(command notEmpty and: [ self obsoleteEsopeCommandNames includes: command first asLowercase ])
			ifTrue: [
				features add: (self obsoleteFunctionFeatureNamed: command first atLine: data first first x) ].
		(command size = 2 and: [ command first asLowercase = 'pointeur' ]) ifTrue: [
			features add: (self segmentFeatureFrom: command second atLine: data first first x) ].
		(command notEmpty and: [ self segmentInstructionNames includes: command first asLowercase ])
			ifTrue: [
				features add: (self segmentInstructionFeatureNamed: command first atLine: data first first x) ] ].
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
FortranFeatureExtractor >> visitDeref: aDerefNode [
	| data kind |
	kind := isAssignmentTarget ifTrue: [ #write ] ifFalse: [ #read ].
	isAssignmentTarget := false.
	data := super visitDeref: aDerefNode.
	isDerefSubscripted ifFalse: [
		features add: (self getSizeFeatureFrom: data index: nil accessKind: kind) ].
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
FortranFeatureExtractor >> visitFunctionWithBlocks: aFunctionNode [
	| data |
	data := super visitFunctionWithBlocks: aFunctionNode.
	features add: (self procedureFeatureNamed: data second ofType: 'FUNCTION' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitFunction_call: aFunctionCallNode [
	"Function invocations used as expressions: result = funcName(...)"
	| data name |
	data := super visitFunction_call: aFunctionCallNode.
	features add: (self invocationFeatureFrom: data).
	name := data second second.
	(self segmentFunctionCallNames includes: name asLowercase) ifTrue: [
		features add: (self segmentFunctionCallFeatureFrom: data) ].
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
FortranFeatureExtractor >> visitSubroutine: aSubroutineNode [
	| data |
	data := super visitSubroutine: aSubroutineNode.
	features add: (self procedureFeatureNamed: data second ofType: 'SUBROUTINE' atLine: data first first x).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitSubscript: aSubscriptNode [
	| data rawExpressionTag previousFlag kind |
	rawExpressionTag := (aSubscriptNode at: 'expression') at: 'tag' ifAbsent: [ nil ].
	kind := isAssignmentTarget ifTrue: [ #write ] ifFalse: [ #read ].
	isAssignmentTarget := false.
	previousFlag := isDerefSubscripted.
	(rawExpressionTag = 'deref') ifTrue: [ isDerefSubscripted := true ].
	data := super visitSubscript: aSubscriptNode.
	isDerefSubscripted := previousFlag.
	(rawExpressionTag = 'deref') ifTrue: [
		features add: (self getSizeFeatureFrom: data second
			index: (self indexStringFrom: data third) accessKind: kind) ].
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitTarget: aTargetNode [
	| data |
	isAssignmentTarget := true.
	data := super visitTarget: aTargetNode.
	isAssignmentTarget := false.
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
