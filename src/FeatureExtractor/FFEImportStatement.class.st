Class {
	#name : 'FFEImportStatement',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'importName',
		'importExtension'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEImportStatement >> importExtension [
	^ importExtension
]

{ #category : 'accessing' }
FFEImportStatement >> importExtension: aString [
	importExtension := aString
]

{ #category : 'accessing' }
FFEImportStatement >> importName [
	^ importName
]

{ #category : 'accessing' }
FFEImportStatement >> importName: aString [
	importName := aString
]
