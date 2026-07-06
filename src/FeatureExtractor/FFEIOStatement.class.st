Class {
	#name : 'FFEIOStatement',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'ioStatementType'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEIOStatement >> ioStatementType [
	^ ioStatementType
]

{ #category : 'accessing' }
FFEIOStatement >> ioStatementType: aString [
	ioStatementType := aString
]
