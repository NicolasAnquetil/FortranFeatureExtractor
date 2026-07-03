"
A FortranFeatureExtractorTest is a test class for testing the behavior of FortranFeatureExtractor
"
Class {
	#name : 'FortranFeatureExtractorTest',
	#superclass : 'TestCase',
	#category : 'FeatureExtractor-Tests-Visitor',
	#package : 'FeatureExtractor-Tests',
	#tag : 'Visitor'
}

{ #category : 'tests' }
FortranFeatureExtractorTest >> testInvocations [
	"       subroutine bla
       call blafun
       end

"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"/Users/meghasudheendran/Desktop/invocationtest.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(2:18)-(2:18)"},"function":{"anno":[],"span":"(2:13)-(2:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(2:8)-(2:18)","tag":"call"},"tag":"statement"}],"name":"bla","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 1.
	self assert: features anyOne class equals: FFEInvocationFeature.
	self assert: features anyOne invokedName equals: 'blafun'.
	self assert: features anyOne lineNumber equals: 2
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> visitJsonCode: jsonCode [
	| visitor |
	visitor := FortranFeatureExtractor new.
	visitor visitProgramFile: (NeoJSONReader fromString: jsonCode).
	^visitor features
]
