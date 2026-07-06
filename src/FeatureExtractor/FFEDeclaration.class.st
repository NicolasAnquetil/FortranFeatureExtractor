Class {
	#name : 'FFEDeclaration',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'declaredName',
		'declaredType'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEDeclaration >> declaredName [
	^ declaredName
]

{ #category : 'accessing' }
FFEDeclaration >> declaredName: aString [
	declaredName := aString
]

{ #category : 'accessing' }
FFEDeclaration >> declaredType [
	^ declaredType 
]

{ #category : 'accessing' }
FFEDeclaration >> declaredType: aString [
	declaredType := aString
]
