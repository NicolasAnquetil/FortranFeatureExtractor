Class {
	#name : 'FFEProcedureDefinition',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'procedureName',
		'procedureType'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEProcedureDefinition >> procedureName [
	^ procedureName
]

{ #category : 'accessing' }
FFEProcedureDefinition >> procedureName: aString [
	procedureName := aString
]

{ #category : 'accessing' }
FFEProcedureDefinition >> procedureType [
	^ procedureType
]

{ #category : 'accessing' }
FFEProcedureDefinition >> procedureType: aString [
	procedureType := aString
]
