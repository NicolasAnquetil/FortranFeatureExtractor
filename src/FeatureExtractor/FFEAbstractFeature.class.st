Class {
	#name : 'FFEAbstractFeature',
	#superclass : 'Object',
	#instVars : [
		'filename',
		'lineNumber'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEAbstractFeature >> filename [
	^ filename
]

{ #category : 'accessing' }
FFEAbstractFeature >> filename: aString [
	filename := aString
]

{ #category : 'accessing' }
FFEAbstractFeature >> lineNumber [
	^ lineNumber
]

{ #category : 'accessing' }
FFEAbstractFeature >> lineNumber: anInteger [
	lineNumber := anInteger
]
