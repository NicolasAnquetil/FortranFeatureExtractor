"
A visitor that extracts features from a Fortran JSON AST.

To use:
```
extractor := FortranFeatureExtractor new.
extractor visitProgramFile: (NeoJSONReader fromString: '/path/to/tmpJsonImport/src/xyz.json' asFileReference contents).
extractor invocations.
```
"
Class {
	#name : 'FortranFeatureExtractor',
	#superclass : 'FortranAbstractJsonVisitor',
	#instVars : [
		'invocations',
		'f77sourcefile'
	],
	#category : 'FeatureExtractor-Visitor',
	#package : 'FeatureExtractor',
	#tag : 'Visitor'
}

{ #category : 'initialization' }
FortranFeatureExtractor >> initialize [
	super initialize.
	invocations := OrderedCollection new.
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

{ #category : 'accessing' }
FortranFeatureExtractor >> invocations [
	^ invocations
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitCallStatement: aCallNode [
	"Subroutine calls: CALL subName(...)"
	| data |
	data := super visitCallStatement: aCallNode.
	invocations add: (self invocationFeatureFrom: data).
	^ data
]

{ #category : 'visiting' }
FortranFeatureExtractor >> visitFunction_call: aFunctionCallNode [
	"Function invocations used as expressions: result = funcName(...)"
	| data |
	data := super visitFunction_call: aFunctionCallNode.
	invocations add: (self invocationFeatureFrom: data).
	^ data
]

{ #category : 'visiting prog-unit' }
FortranFeatureExtractor >> visitMiFilename: aString [
	f77sourcefile := aString
]
