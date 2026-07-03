Class {
	#name : 'FFEControFlowStatement',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'controFlowStatementName'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEControFlowStatement >> controFlowStatementName [
	^ controFlowStatementName
]

{ #category : 'accessing' }
FFEControFlowStatement >> controFlowStatementName: aString [
	controFlowStatementName := aString
]
