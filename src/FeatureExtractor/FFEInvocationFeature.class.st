Class {
	#name : 'FFEInvocationFeature',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'invokedName'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEInvocationFeature >> invokedName [
	^ invokedName
]

{ #category : 'accessing' }
FFEInvocationFeature >> invokedName: aString [
	invokedName := aString
]
