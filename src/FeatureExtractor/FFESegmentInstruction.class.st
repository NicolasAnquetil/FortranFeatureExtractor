Class {
	#name : 'FFESegmentInstruction',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'invokedSegmentFunctionName'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFESegmentInstruction >> invokedSegmentFunctionName [
	^ invokedSegmentFunctionName
]

{ #category : 'accessing' }
FFESegmentInstruction >> invokedSegmentFunctionName: aString [
	invokedSegmentFunctionName := aString
]
