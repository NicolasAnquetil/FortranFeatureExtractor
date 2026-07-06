Class {
	#name : 'FFEExpression',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'operator'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEExpression >> operator [
	^ operator
]

{ #category : 'accessing' }
FFEExpression >> operator: aString [
	operator := aString
]
