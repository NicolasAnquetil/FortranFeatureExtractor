Class {
	#name : 'FFESegmentFunctionCall',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'arguments',
		'targetName'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFESegmentFunctionCall >> arguments [
	^ arguments
]

{ #category : 'accessing' }
FFESegmentFunctionCall >> arguments: aCollection [
	arguments := aCollection
]

{ #category : 'accessing' }
FFESegmentFunctionCall >> targetName [
	^ targetName
]

{ #category : 'accessing' }
FFESegmentFunctionCall >> targetName: aString [
	targetName := aString
]
