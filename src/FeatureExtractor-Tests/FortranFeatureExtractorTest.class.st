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
FortranFeatureExtractorTest >> testIf [
	"       subroutine bla
       if (x .gt. 0) then
       call blafun
       end if
       end

"

	| features ifFeature endIfFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"iftest.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":null,"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:12)-(2:12)","tag":"value","value":{"contents":"x","tag":"variable"}},"op":{"tag":"gt"},"right":{"anno":[],"span":"(2:19)-(2:19)","tag":"value","value":{"contents":["0",null],"tag":"integer"}},"span":"(2:12)-(2:19)","tag":"binary"},[{"anno":[],"label":null,"span":"(3:8)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:18)-(3:18)"},"function":{"anno":[],"span":"(3:13)-(3:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(3:8)-(3:18)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(4:13)","tag":"if"}],"name":"bla","options":[null,null],"span":"(1:8)-(5:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	
	ifFeature := features detect: [:f | f lineNumber = 2].
	endIfFeature := features detect: [:f | f lineNumber = 4].
	
	self assert: ifFeature class equals: FFEControFlowStatement .
	self assert: endIfFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testInvocations [
	"       subroutine bla
       call blafun
       end

"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"invocationtest.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(2:18)-(2:18)"},"function":{"anno":[],"span":"(2:13)-(2:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(2:8)-(2:18)","tag":"call"},"tag":"statement"}],"name":"bla","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

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
