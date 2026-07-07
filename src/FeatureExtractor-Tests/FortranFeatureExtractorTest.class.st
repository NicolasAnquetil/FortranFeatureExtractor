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
FortranFeatureExtractorTest >> testAdditionExpression [
	"       subroutine foo
       integer x
       x = 2 + 3
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"op":{"tag":"addition"},"right":{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"span":"(3:12)-(3:16)","tag":"binary"},"span":"(3:8)-(3:16)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '+' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testCharacterDeclaration [ 
	"       subroutine bla
       character name
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:18)-(2:21)","type":"scalar","variable":{"anno":[],"span":"(2:18)-(2:21)","tag":"value","value":{"contents":"name","tag":"variable"}}}],"span":"(2:18)-(2:21)"},"span":"(2:8)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"character","selector":null,"span":"(2:8)-(2:16)"}},"tag":"statement"}],"name":"bla","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEDeclaration]) class equals: FFEDeclaration .
	self assert: (features detect: [:f | f class = FFEDeclaration]) declaredName equals: 'name'.
	self assert: (features detect: [:f | f class = FFEDeclaration]) declaredType equals: 'CHARACTER'
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testClose [
	"      subroutine foo
      close(10)
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"/Users/meghasudheendran/Desktop/test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"span":"(2:7)-(2:15)","specification":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(2:13)-(2:14)","tag":"value","value":{"contents":["10",null],"tag":"integer"}},"name":null,"span":"(2:13)-(2:14)"}],"span":"(2:12)-(2:15)"},"tag":"close"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEIOStatement]) class equals: FFEIOStatement . 
	self assert: (features detect: [:f | f class = FFEIOStatement]) ioStatementType equals: 'CLOSE' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testContinue [
	"       subroutine cnti
   10  continue
       call toto
       end
"

	| features continueFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"ifelse.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":{"anno":[],"span":"(2:4)-(2:5)","tag":"value","value":{"contents":["10",null],"tag":"integer"}},"span":"(2:4)-(2:15)","statement":{"anno":[],"span":"(2:8)-(2:15)","tag":"continue"},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:16)-(3:16)"},"function":{"anno":[],"span":"(3:13)-(3:16)","tag":"value","value":{"contents":"toto","tag":"variable"}},"span":"(3:8)-(3:16)","tag":"call"},"tag":"statement"}],"name":"cnti","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	
	continueFeature := features detect: [:f | f lineNumber = 2].
	
	self assert: continueFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testDeclarations [ 
	"       subroutine foo
       character name
       integer i
       real ratio
       logical status
       external toto
       parameter(n=2)

       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:18)-(2:21)","type":"scalar","variable":{"anno":[],"span":"(2:18)-(2:21)","tag":"value","value":{"contents":"name","tag":"variable"}}}],"span":"(2:18)-(2:21)"},"span":"(2:8)-(2:21)","tag":"declaration","type":{"anno":[],"base_type":"character","selector":null,"span":"(2:8)-(2:16)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(3:16)-(3:16)","type":"scalar","variable":{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":"i","tag":"variable"}}}],"span":"(3:16)-(3:16)"},"span":"(3:8)-(3:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(3:8)-(3:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(4:8)-(4:17)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(4:13)-(4:17)","type":"scalar","variable":{"anno":[],"span":"(4:13)-(4:17)","tag":"value","value":{"contents":"ratio","tag":"variable"}}}],"span":"(4:13)-(4:17)"},"span":"(4:8)-(4:17)","tag":"declaration","type":{"anno":[],"base_type":"real","selector":null,"span":"(4:8)-(4:11)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(5:8)-(5:21)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(5:16)-(5:21)","type":"scalar","variable":{"anno":[],"span":"(5:16)-(5:21)","tag":"value","value":{"contents":"status","tag":"variable"}}}],"span":"(5:16)-(5:21)"},"span":"(5:8)-(5:21)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(5:8)-(5:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(6:8)-(6:20)","statement":{"anno":[],"span":"(6:8)-(6:20)","tag":"external","vars":{"anno":[],"list":[{"anno":[],"span":"(6:17)-(6:20)","tag":"value","value":{"contents":"toto","tag":"variable"}}],"span":"(6:17)-(6:20)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(7:8)-(7:21)","statement":{"anno":[],"declarators":{"anno":[],"list":[{"anno":[],"initial":{"anno":[],"span":"(7:20)-(7:20)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"length":null,"span":"(7:18)-(7:20)","type":"scalar","variable":{"anno":[],"span":"(7:18)-(7:18)","tag":"value","value":{"contents":"n","tag":"variable"}}}],"span":"(7:18)-(7:20)"},"span":"(7:8)-(7:21)","tag":"parameter"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(9:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 7.
	self assert: (features detect: [:f | f lineNumber = 2]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 3]) declaredName equals: 'i'.
	self assert: (features detect: [:f | f lineNumber = 3]) declaredType equals: 'INTEGER'.
	
	self assert: (features detect: [:f | f lineNumber = 4]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 4]) declaredName equals: 'ratio'.
	self assert: (features detect: [:f | f lineNumber = 4]) declaredType equals: 'REAL'.
	
	self assert: (features detect: [:f | f lineNumber = 5]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 5]) declaredName equals: 'status'.
	self assert: (features detect: [:f | f lineNumber = 5]) declaredType equals: 'LOGICAL'.
	
	self assert: (features detect: [:f | f lineNumber = 6]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 6]) declaredName equals: 'toto'.
	self assert: (features detect: [:f | f lineNumber = 6]) declaredType equals: 'EXTERNAL'.
	
	self assert: (features detect: [:f | f lineNumber = 7]) class equals: FFEDeclaration.
	self assert: (features detect: [:f | f lineNumber = 7]) declaredName equals: 'n'.
	self assert: (features detect: [:f | f lineNumber = 7]) declaredType equals: 'PARAMETER'.
	
	
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testDivisionExpression [
	"       subroutine foo
       integer x
       x = 2 / 3
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"op":{"tag":"division"},"right":{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"span":"(3:12)-(3:16)","tag":"binary"},"span":"(3:8)-(3:16)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '/' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testEQExpression [
	"       subroutine foo
       logical x
       x = 1 .EQ. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"eq"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.EQ.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testExponentiationExpression [
	"       subroutine foo
       integer x
       x = 2 ** 3
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:17)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"op":{"tag":"exponentiation"},"right":{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"span":"(3:12)-(3:17)","tag":"binary"},"span":"(3:8)-(3:17)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '**' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testFunctionDefinition [
	"       integer function foo()
       end
"

	| features feature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[],"name":"foo","result":null,"span":"(1:8)-(2:10)","subprograms":null,"tag":"function","type":{"anno":[],"base_type":"integer","selector":null,"span":"(1:8)-(1:14)"}}]}'.

	self assert: features size equals: 1.

	feature := features first.
	self assert: feature class equals: FFEProcedureDefinition.
	self assert: feature procedureName equals: 'foo'.
	self assert: feature procedureType equals: 'FUNCTION'.
	self assert: feature lineNumber equals: 1.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testGEExpression [
	"       subroutine foo
       logical x
       x = 1 .GE. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"gte"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.GE.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testGTExpression [
	"       subroutine foo
       logical x
       x = 1 .GT. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"gt"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.GT.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testIf [
	"       subroutine bla
       if (.true.) then
       call blafun
       end if
       end

"

	| features ifFeature endIfFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":null,"conditions":[[{"anno":[],"span":"(2:12)-(2:17)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},[{"anno":[],"label":null,"span":"(3:8)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:18)-(3:18)"},"function":{"anno":[],"span":"(3:13)-(3:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(3:8)-(3:18)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(4:13)","tag":"if"}],"name":"bla","options":[null,null],"span":"(1:8)-(5:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 4.
	
	ifFeature := features detect: [:f | f lineNumber = 2].
	endIfFeature := features detect: [:f | f lineNumber = 4].
	
	self assert: ifFeature class equals: FFEControFlowStatement .
	self assert: endIfFeature class equals: FFEControFlowStatement .
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testIfElse [
	"       subroutine ifelse
       if (.true.) then
       call blafun
       else
       call toto
       end if
       end
"

	| features ifFeature endIfFeature elseFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(5:8)-(5:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(5:16)-(5:16)"},"function":{"anno":[],"span":"(5:13)-(5:16)","tag":"value","value":{"contents":"toto","tag":"variable"}},"span":"(5:8)-(5:16)","tag":"call"},"tag":"statement"}],"conditions":[[{"anno":[],"span":"(2:12)-(2:17)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},[{"anno":[],"label":null,"span":"(3:8)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:18)-(3:18)"},"function":{"anno":[],"span":"(3:13)-(3:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(3:8)-(3:18)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(6:13)","tag":"if"}],"name":"ifelse","options":[null,null],"span":"(1:8)-(7:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 6.
	
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
       if (.true.) then
       call toto1
       else if (.false.) then
       call toto2
       else
       call toto3
       end if
       end
"

	| features ifFeature endIfFeature elseFeature elseifFeature|
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"blocks":[{"anno":[],"label":null,"span":"(7:8)-(7:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(7:17)-(7:17)"},"function":{"anno":[],"span":"(7:13)-(7:17)","tag":"value","value":{"contents":"toto3","tag":"variable"}},"span":"(7:8)-(7:17)","tag":"call"},"tag":"statement"}],"conditions":[[{"anno":[],"span":"(2:12)-(2:17)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},[{"anno":[],"label":null,"span":"(3:8)-(3:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:17)-(3:17)"},"function":{"anno":[],"span":"(3:13)-(3:17)","tag":"value","value":{"contents":"toto1","tag":"variable"}},"span":"(3:8)-(3:17)","tag":"call"},"tag":"statement"}]],[{"anno":[],"span":"(4:17)-(4:23)","tag":"value","value":{"contents":[false,null],"tag":"logical"}},[{"anno":[],"label":null,"span":"(5:8)-(5:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(5:17)-(5:17)"},"function":{"anno":[],"span":"(5:13)-(5:17)","tag":"value","value":{"contents":"toto2","tag":"variable"}},"span":"(5:8)-(5:17)","tag":"call"},"tag":"statement"}]]],"end_label":null,"label":null,"name":null,"span":"(2:8)-(8:13)","tag":"if"}],"name":"elseif","options":[null,null],"span":"(1:8)-(9:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 8.
	
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
FortranFeatureExtractorTest >> testInclude [
	"      subroutine hello( )
c@_#include ""file.inc""
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"<stdin>"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_#include \"file.inc\"","span":"(2:1)-(2:22)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEImportStatement]) class equals: FFEImportStatement . 
	self assert: (features detect: [:f | f class = FFEImportStatement]) importName equals: 'file' . 
	self assert: (features detect: [:f | f class = FFEImportStatement]) importExtension equals: '.inc' . 
	
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testIncludeSeg [
	"      subroutine hello( )
c@_#include ""file.seg""
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_#include \"file.seg\"","span":"(2:1)-(2:22)","tag":"comment"}],"name":"hello","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEImportStatement]) class equals: FFEImportStatement . 
	self assert: (features detect: [:f | f class = FFEImportStatement]) importName equals: 'file' . 
	self assert: (features detect: [:f | f class = FFEImportStatement]) importExtension equals: '.seg' . 
	
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testInvocations [
	"       subroutine bla
       call blafun
       end

"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"invocationtest.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(2:18)-(2:18)"},"function":{"anno":[],"span":"(2:13)-(2:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(2:8)-(2:18)","tag":"call"},"tag":"statement"}],"name":"bla","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEInvocationFeature]) class equals: FFEInvocationFeature.
	self assert: (features detect: [:f | f class = FFEInvocationFeature]) invokedName equals: 'blafun'.
	self assert: (features detect: [:f | f class = FFEInvocationFeature]) lineNumber equals: 2
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testLEExpression [
	"       subroutine foo
       logical x
       x = 1 .LE. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"lte"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.LE.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testLTExpression [
	"       subroutine foo
       logical x
       x = 1 .LT. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"lt"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.LT.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testLogicalAndExpression [
	"       subroutine foo
       logical c
       c = .true. .AND. .false.
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"c","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:31)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:17)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},"op":{"tag":"and"},"right":{"anno":[],"span":"(3:25)-(3:31)","tag":"value","value":{"contents":[false,null],"tag":"logical"}},"span":"(3:12)-(3:31)","tag":"binary"},"span":"(3:8)-(3:31)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"c","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.AND.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testLogicalNOTExpression [
	"      subroutine foo
       logical b
       b = .NOT. .true.
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"b","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:23)","statement":{"anno":[],"expression":{"anno":[],"expression":{"anno":[],"span":"(3:18)-(3:23)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},"op":{"tag":"not"},"span":"(3:12)-(3:23)","tag":"unary"},"span":"(3:8)-(3:23)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"b","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.NOT.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testLogicalORExpression [
	"      subroutine foo
       logical c
       c = .true. .OR. .false.
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"c","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:30)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:17)","tag":"value","value":{"contents":[true,null],"tag":"logical"}},"op":{"tag":"or"},"right":{"anno":[],"span":"(3:24)-(3:30)","tag":"value","value":{"contents":[false,null],"tag":"logical"}},"span":"(3:12)-(3:30)","tag":"binary"},"span":"(3:8)-(3:30)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"c","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.OR.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testMultiplicationExpression [
	"       subroutine foo
       integer x
       x = 2 * 3
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"op":{"tag":"multiplication"},"right":{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"span":"(3:12)-(3:16)","tag":"binary"},"span":"(3:8)-(3:16)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '*' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testNEExpression [
	"       subroutine foo
       logical x
       x = 1 .NE. 2
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"logical","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:19)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"op":{"tag":"ne"},"right":{"anno":[],"span":"(3:19)-(3:19)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"span":"(3:12)-(3:19)","tag":"binary"},"span":"(3:8)-(3:19)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '.NE.' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testObsoleteCall [
	"       subroutine foo
       call oooeta(lib)
       end
"

	| features invocation obsolete |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:22)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:19)-(2:21)","tag":"value","value":{"contents":"lib","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:19)-(2:21)"}],"span":"(2:18)-(2:22)"},"function":{"anno":[],"span":"(2:12)-(2:17)","tag":"value","value":{"contents":"oooeta","tag":"variable"}},"span":"(2:7)-(2:22)","tag":"call"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.

	invocation := features detect: [:f | f class = FFEInvocationFeature].
	obsolete := features detect: [:f | f class = FFEObsoleteFunction].

	self assert: invocation invokedName equals: 'oooeta'.
	self assert: obsolete obsoleteFunctionName equals: 'oooeta'.
	self assert: obsolete lineNumber equals: 2.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testObsoleteEsopeCommands [
	"       subroutine foo
c@_    segact, lb
c@_    segdes, lb*MOD
       end
"

	| features segactFeature segdesFeature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_    segact, lb","span":"(2:1)-(2:19)","tag":"comment"},{"anno":[],"comment":"@_    segdes, lb*MOD","span":"(3:1)-(3:23)","tag":"comment"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 5.

	segactFeature := features detect: [:f | f lineNumber = 2].
	segdesFeature := features detect: [:f | f lineNumber = 3].

	self assert: segactFeature class equals: FFEObsoleteFunction.
	self assert: segactFeature obsoleteFunctionName equals: 'segact'.

	self assert: segdesFeature class equals: FFEObsoleteFunction.
	self assert: segdesFeature obsoleteFunctionName equals: 'segdes'.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testOpen [
	"      subroutine foo
      OPEN(unit=10, file= 'f.txt')
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:34)","statement":{"anno":[],"span":"(2:7)-(2:34)","specification":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(2:17)-(2:18)","tag":"value","value":{"contents":["10",null],"tag":"integer"}},"name":"unit","span":"(2:12)-(2:18)"},{"anno":[],"expr":{"anno":[],"span":"(2:27)-(2:33)","tag":"value","value":{"contents":"f.txt","tag":"string"}},"name":"file","span":"(2:21)-(2:33)"}],"span":"(2:11)-(2:34)"},"tag":"open"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(3:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.
	self assert: (features detect: [:f | f class = FFEIOStatement]) class equals: FFEIOStatement . 
	self assert: (features detect: [:f | f class = FFEIOStatement]) ioStatementType equals: 'OPEN' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testPointeurSegment [
	"       subroutine foo
c@_    pointeur lb.tlib
       end
"

	| features feature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_    pointeur lb.tlib","span":"(2:1)-(2:23)","tag":"comment"}],"name":"foo","options":[null,null],"span":"(1:8)-(3:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 2.

	feature := features detect: [:f | f class = FFESegment].
	self assert: feature segmentName equals: 'pointeur'.
	self assert: feature segmentType equals: 'lb.tlib'.
	self assert: feature lineNumber equals: 2.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testPrint [
	"      subroutine foo
      integer x
      print *, x
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:15)-(2:15)"},"span":"(2:7)-(2:15)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:16)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":"x","tag":"variable"}}],"span":"(3:16)-(3:16)"},"format":{"anno":[],"span":"(3:13)-(3:13)","tag":"value","value":{"tag":"star"}},"span":"(3:7)-(3:16)","tag":"print"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEIOStatement . 
	self assert: (features detect: [:f | f lineNumber = 3]) ioStatementType equals: 'PRINT' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testRead [
	"      subroutine foo
      integer x
      read(*,*) x
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:15)-(2:15)"},"span":"(2:7)-(2:15)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:17)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(3:17)-(3:17)","tag":"value","value":{"contents":"x","tag":"variable"}}],"span":"(3:17)-(3:17)"},"format":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(3:12)-(3:12)"},{"anno":[],"expr":{"anno":[],"span":"(3:14)-(3:14)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(3:14)-(3:14)"}],"span":"(3:11)-(3:15)"},"span":"(3:7)-(3:17)","tag":"read"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEIOStatement . 
	self assert: (features detect: [:f | f lineNumber = 3]) ioStatementType equals: 'READ' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testSegmentFunctionCall [
	"       subroutine foo
       x = mypnt(lib, 1)
       call blafun
       end
"

	| features mypntFeature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:25)","statement":{"anno":[],"expression":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:19)-(2:21)","tag":"value","value":{"contents":"lib","tag":"variable"}},"tag":"expr"},"name":null,"span":"(2:19)-(2:21)"},{"anno":[],"expr":{"contents":{"anno":[],"span":"(2:24)-(2:24)","tag":"value","value":{"contents":["1",null],"tag":"integer"}},"tag":"expr"},"name":null,"span":"(2:24)-(2:24)"}],"span":"(2:18)-(2:25)"},"function":{"anno":[],"span":"(2:12)-(2:17)","tag":"value","value":{"contents":"mypnt","tag":"variable"}},"span":"(2:12)-(2:25)","tag":"function_call"},"span":"(2:8)-(2:25)","tag":"assign_expression","target":{"anno":[],"span":"(2:8)-(2:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[],"span":"(3:18)-(3:18)"},"function":{"anno":[],"span":"(3:13)-(3:18)","tag":"value","value":{"contents":"blafun","tag":"variable"}},"span":"(3:8)-(3:18)","tag":"call"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: (features count: [:f | f class = FFESegmentFunctionCall]) equals: 1.

	mypntFeature := features detect: [:f | f class = FFESegmentFunctionCall].
	self assert: mypntFeature targetName equals: 'mypnt'.
	self assert: mypntFeature lineNumber equals: 2.

	"arguments is a collection of {argSpan. {valueSpan. valueString}} pairs -- dig into the
	 2nd-of-2nd slot to reach the actual argument value"
	self assert: mypntFeature arguments size equals: 2.
	self assert: (mypntFeature arguments first) second second equals: 'lib'.
	self assert: (mypntFeature arguments second) second second equals: '1'.

	"blafun is not mypnt and must not produce a FFESegmentFunctionCall"
	self assert: (features anySatisfy: [:f | f class = FFEInvocationFeature and: [f invokedName = 'blafun']]).
	self deny: (features anySatisfy: [:f | f class = FFESegmentFunctionCall and: [f targetName = 'blafun']]).
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testSegmentInstructionFeature [
	"       subroutine foo
c@_    segini, bk
c@_    segact, lb
       end
"

	| features seginiFeature segactInstrFeature segactObsoleteFeature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"comment":"@_    segini, bk","span":"(2:1)-(2:19)","tag":"comment"},{"anno":[],"comment":"@_    segact, lb","span":"(3:1)-(3:19)","tag":"comment"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	seginiFeature := features detect: [:f | f class = FFESegmentInstruction and: [f lineNumber = 2]].
	self assert: seginiFeature invokedSegmentFunctionName equals: 'segini'.

	"segact must count both as an obsolete function and as a segment instruction (additive)"
	segactObsoleteFeature := features detect: [:f | f class = FFEObsoleteFunction and: [f lineNumber = 3]].
	segactInstrFeature := features detect: [:f | f class = FFESegmentInstruction and: [f lineNumber = 3]].
	self assert: segactObsoleteFeature obsoleteFunctionName equals: 'segact'.
	self assert: segactInstrFeature invokedSegmentFunctionName equals: 'segact'.

	self assert: (features count: [:f | f class = FFESegmentInstruction]) equals: 2.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testSubroutineDefinition [
	"       subroutine foo
       end
"

	| features feature |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[],"name":"foo","options":[null,null],"span":"(1:8)-(2:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 1.

	feature := features first.
	self assert: feature class equals: FFEProcedureDefinition.
	self assert: feature procedureName equals: 'foo'.
	self assert: feature procedureType equals: 'SUBROUTINE'.
	self assert: feature lineNumber equals: 1.
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testSubtractionExpression [
	"       subroutine foo
       integer x
       x = 2 - 3
       end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:8)-(2:16)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:16)-(2:16)","type":"scalar","variable":{"anno":[],"span":"(2:16)-(2:16)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:16)-(2:16)"},"span":"(2:8)-(2:16)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:8)-(2:14)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:8)-(3:16)","statement":{"anno":[],"expression":{"anno":[],"left":{"anno":[],"span":"(3:12)-(3:12)","tag":"value","value":{"contents":["2",null],"tag":"integer"}},"op":{"tag":"subtraction"},"right":{"anno":[],"span":"(3:16)-(3:16)","tag":"value","value":{"contents":["3",null],"tag":"integer"}},"span":"(3:12)-(3:16)","tag":"binary"},"span":"(3:8)-(3:16)","tag":"assign_expression","target":{"anno":[],"span":"(3:8)-(3:8)","tag":"value","value":{"contents":"x","tag":"variable"}}},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:8)-(4:10)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEExpression . 
	self assert: (features detect: [:f | f lineNumber = 3]) operator equals: '-' . 
	
]

{ #category : 'tests' }
FortranFeatureExtractorTest >> testWrite [
	"      subroutine foo
      integer x
      write(*,*) x
      end
"

	| features |
	features := self visitJsonCode: '{"meta":{"miVersion":"fortran77","miFilename":"test.f"},"program_units":[{"anno":[],"arguments":null,"blocks":[{"anno":[],"label":null,"span":"(2:7)-(2:15)","statement":{"anno":[],"attributes":null,"declarators":{"anno":[],"list":[{"anno":[],"initial":null,"length":null,"span":"(2:15)-(2:15)","type":"scalar","variable":{"anno":[],"span":"(2:15)-(2:15)","tag":"value","value":{"contents":"x","tag":"variable"}}}],"span":"(2:15)-(2:15)"},"span":"(2:7)-(2:15)","tag":"declaration","type":{"anno":[],"base_type":"integer","selector":null,"span":"(2:7)-(2:13)"}},"tag":"statement"},{"anno":[],"label":null,"span":"(3:7)-(3:18)","statement":{"anno":[],"arguments":{"anno":[],"list":[{"anno":[],"span":"(3:18)-(3:18)","tag":"value","value":{"contents":"x","tag":"variable"}}],"span":"(3:18)-(3:18)"},"format":{"anno":[],"list":[{"anno":[],"expr":{"anno":[],"span":"(3:13)-(3:13)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(3:13)-(3:13)"},{"anno":[],"expr":{"anno":[],"span":"(3:15)-(3:15)","tag":"value","value":{"tag":"star"}},"name":null,"span":"(3:15)-(3:15)"}],"span":"(3:12)-(3:16)"},"span":"(3:7)-(3:18)","tag":"write"},"tag":"statement"}],"name":"foo","options":[null,null],"span":"(1:7)-(4:9)","subprograms":null,"tag":"subroutine"}]}'.

	self assert: features size equals: 3.
	self assert: (features detect: [:f | f lineNumber = 3]) class equals: FFEIOStatement . 
	self assert: (features detect: [:f | f lineNumber = 3]) ioStatementType equals: 'WRITE' . 
	
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

	self assert: features size equals: 4.
	
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

	self assert: features size equals: 2.
	
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
