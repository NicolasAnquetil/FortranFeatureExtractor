Class {
	#name : 'FFEESOPEMemberAccess',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'baseName',
		'memberName',
		'index',
		'accessKind'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFEESOPEMemberAccess >> accessKind [
	^ accessKind
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> accessKind: aSymbol [
	accessKind := aSymbol
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> baseName [
	^ baseName
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> baseName: aString [
	baseName := aString
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> index [
	^ index
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> index: aStringOrNil [
	index := aStringOrNil
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> memberName [
	^ memberName
]

{ #category : 'accessing' }
FFEESOPEMemberAccess >> memberName: aString [
	memberName := aString
]
