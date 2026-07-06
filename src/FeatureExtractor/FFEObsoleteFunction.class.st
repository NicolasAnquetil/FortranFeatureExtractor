Class {
	#name : 'FFEObsoleteFunction',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'obsoleteFunctionName'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEObsoleteFunction >> obsoleteFunctionName [
	^ obsoleteFunctionName
]

{ #category : 'accessing' }
FFEObsoleteFunction >> obsoleteFunctionName: aString [
	obsoleteFunctionName := aString
]
