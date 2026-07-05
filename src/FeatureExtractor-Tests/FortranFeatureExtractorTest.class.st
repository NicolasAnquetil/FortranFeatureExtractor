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
FortranFeatureExtractorTest >> testContinue [
	"       subroutine cnti
   10  continue
       call toto
       end
"

	| features continueFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":{"anno":[],"span":"(2:4)-(2:5)","tag":"value","value":{"contents":["10",null],"tag":"integer"}},"span":"(2:4)-(2:15)","statement":{"anno":[],"span":"(2:8)-(2:15)","tag":"continue"},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:16)-(3:16)"},"function":{"anno":[],"span":"(3:13)-(3:16)","tag":"value","value":{"contents":"toto","tag":"variable"}},"span":"(3:8)-(3:16)","tag":"call"},"tag":"statement"}],"name":"cnti","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	
	continueFeature := features detect: [:f | f lineNumber = 2].
	
	self assert: continueFeature class equals: FFEControFlowStatement .
	
]

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
FortranFeatureExtractorTest >> testIfElse [
	"       subroutine ifelse
       if (x .gt. 0) then
       call blafun
       else
       call toto
       end if
       end
"

	| features ifFeature endIfFeature elseFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(5:8)-(5:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(5:16)-(5:16)"},"function":{"anno":[],"span":"(5:13)-(5:16)","tag":"value","value":{"contents":"toto","tag":"variable"}},"span":"(5:8)-(5:16)","tag":"call"},"tag":"statement"}],"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:12)-(2:12)","tag":"value","value":{"contents":"x","tag":"variable"}},"op":{"tag":"gt"},"right":{"anno":[],"span":"(2:19)-(2:19)","tag":"value","value":{"contents":["0",null],"tag":"integer"}},"span":"(2:12)-(2:19)","tag":"binary"},[{"anno":[],"label":null,"span":"(3:8)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:18)-(3:18)"},"function":{"anno":[],"span":"(3:13)-(3:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(3:8)-(3:18)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(6:13)","tag":"if"}],"name":"ifelse","options":[null,null],"span":"(1:8)-(7:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 5.
	
	ifFeature := features detect: [:f | f lineNumber = 2].
	elseFeature := features detect: [:f | f lineNumber = 4].
	endIfFeature := features detect: [:f | f lineNumber = 6].
	self assert: ifFeature class equals: FFEControFlowStatement .
	self assert: elseFeature class equals: FFEControFlowStatement .
	self assert: endIfFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testIfElseIf [
	"       subroutine elseif
       if (x .gt. 0) then
       call toto1
       else if (x .lt. 0) then
       call toto2
       else
       call toto3
       end if
       end
"

	| features ifFeature endIfFeature elseFeature elseifFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(7:8)-(7:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(7:17)-(7:17)"},"function":{"anno":[],"span":"(7:13)-(7:17)","tag":"value","value":{"contents":"toto3","tag":"variable"}},"span":"(7:8)-(7:17)","tag":"call"},"tag":"statement"}],"conditions":[[{"anno":[],"left":{"anno":[],"span":"(2:12)-(2:12)","tag":"value","value":{"contents":"x","tag":"variable"}},"op":{"tag":"gt"},"right":{"anno":[],"span":"(2:19)-(2:19)","tag":"value","value":{"contents":["0",null],"tag":"integer"}},"span":"(2:12)-(2:19)","tag":"binary"},[{"anno":[],"label":null,"span":"(3:8)-(3:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:17)-(3:17)"},"function":{"anno":[],"span":"(3:13)-(3:17)","tag":"value","value":{"contents":"toto1","tag":"variable"}},"span":"(3:8)-(3:17)","tag":"call"},"tag":"statement"}]],[{"anno":[],"left":{"anno":[],"span":"(4:17)-(4:17)","tag":"value","value":{"contents":"x","tag":"variable"}},"op":{"tag":"lt"},"right":{"anno":[],"span":"(4:24)-(4:24)","tag":"value","value":{"contents":["0",null],"tag":"integer"}},"span":"(4:17)-(4:24)","tag":"binary"},[{"anno":[],"label":null,"span":"(5:8)-(5:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(5:17)-(5:17)"},"function":{"anno":[],"span":"(5:13)-(5:17)","tag":"value","value":{"contents":"toto2","tag":"variable"}},"span":"(5:8)-(5:17)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(8:13)","tag":"if"}],"name":"elseif","options":[null,null],"span":"(1:8)-(9:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 7.
	
	ifFeature := features detect: [:f | f lineNumber = 2].
	elseifFeature := features detect: [:f | f lineNumber = 4].
	elseFeature := features detect: [:f | f lineNumber = 6].
	endIfFeature := features detect: [:f | f lineNumber = 8].
	self assert: ifFeature class equals: FFEControFlowStatement .
	self assert: elseFeature class equals: FFEControFlowStatement .
	self assert: endIfFeature class equals: FFEControFlowStatement .
	self assert: elseifFeature class equals: FFEControFlowStatement .
	
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
FortranFeatureExtractorTest >> testdo [
	"       subroutine blado
       do 20 ibk2 = 1, 5
       call toto
   20  continue
       end 
"

	| features doFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"/Users/meghasudheendran/Desktop/ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"body":[{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:16)-(3:16)"},"function":{"anno":[],"span":"(3:13)-(3:16)","tag":"value","value":{"contents":"toto","tag":"variable"}},"span":"(3:8)-(3:16)","tag":"call"},"tag":"statement"}],"do_spec":{"anno":[],"increment":null,"initial":{"anno":[],"expression":{"anno":[],"span":"(2:21)-(2:21)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"span":"(2:14)-(2:21)","tag":"assign_expression","target":{"anno":[],"span":"(2:14)-(2:17)","tag":"value","value":{"contents":"ibk2","tag":"variable"}}},"limit":{"anno":[],"span":"(2:24)-(2:24)","tag":"value","value":{"contents":["5",null],"tag":"integer"}},"span":"(2:14)-(2:24)"},"end_label":{"anno":[],"span":"(4:4)-(4:5)","tag":"value","value":{"contents":["20",null],"tag":"integer"}},"label":null,"name":null,"span":"(2:8)-(3:16)","tag":"do","target":{"anno":[],"span":"(2:11)-(2:12)","tag":"value","value":{"contents":["20",null],"tag":"integer"}}}],"name":"blado","options":[null,null],"span":"(1:8)-(5:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	
	doFeature := features detect: [:f | f lineNumber = 2].
	
	self assert: doFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testgoto [
	"       subroutine blagt
       goto 10
       end
"

	| features continueFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:14)","statement":{"anno":[],"span":"(2:8)-(2:14)","tag":"goto","target":{"anno":[],"span":"(2:13)-(2:14)","tag":"value","value":{"contents":["10",null],"tag":"integer"}}},"tag":"statement"}],"name":"blagt","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 1.
	
	continueFeature := features detect: [:f | f lineNumber = 2].
	
	self assert: continueFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> visitJsonCode: jsonCode [
	| visitor |
	visitor := FortranFeatureExtractor new.
	visitor visitProgramFile: (NeoJSONReader fromString: jsonCode).
	^visitor features
]
