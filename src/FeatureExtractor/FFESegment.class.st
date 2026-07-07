Class {
	#name : 'FFESegment',
	#superclass : 'FFEAbstractFeature',
	#instVars : [
		'segmentName',
		'segmentType'
	],
	#category : 'FeatureExtractor-DataModel',
	#package : 'FeatureExtractor',
	#tag : 'DataModel'
}

{ #category : 'accessing' }
FFESegment >> segmentName [
	^ segmentName
]

{ #category : 'accessing' }
FFESegment >> segmentName: aString [
	segmentName := aString
]

{ #category : 'accessing' }
FFESegment >> segmentType [
	^ segmentType
]

{ #category : 'accessing' }
FFESegment >> segmentType: aString [
	segmentType := aString
]
