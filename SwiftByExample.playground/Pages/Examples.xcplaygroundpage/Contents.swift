import XCTest
import Foundation

//: Necessary code to make Learning Swift by Example work

class SwiftExample<T : Equatable> {
    private var code : (() -> T)
    private var expectedResult : (() -> T)!
    
    init(code : @escaping () -> T){
        self.code = code
    }
    
    func returns(expectedResult : @escaping () -> T) -> SwiftExample<T>{
        self.expectedResult = expectedResult
        return self
    }
    
    func runExample() {
        XCTAssertEqual(code(), expectedResult())
    }
}

func thisCode<T>(code : @escaping () -> T) -> SwiftExample<T>{
    return SwiftExample<T>(code: code)
}

class SwiftExamplesTest : XCTestCase{
    class func addTestForExample<T>(example : SwiftExample<T>, withName name : String){
        let testToRun = { example.runExample() }
        let implementation = imp_implementationWithBlock(unsafeBitCast(testToRun as @convention(block) () -> (), to: AnyObject.self))
        let methodName = Selector(name)
        let types = "v@:"
        class_addMethod(self, methodName, implementation, types)
    }
}

extension String {
    func forExample<T>(_ examples : SwiftExample<T>...){
        forExample(examples)
    }
    
    func forInstance<T>(_ examples : SwiftExample<T>...){
        forExample(examples)
    }
    
    func i_e<T>(_ examples : SwiftExample<T>...){
        forExample(examples)
    }
    
    private func forExample<T>(_ examples : [SwiftExample<T>]){
        for (index, example) in examples.enumerated(){
            let methodName = getMethodName(index: index);
            SwiftExamplesTest.addTestForExample(example: example, withName: methodName)
        }
    }
    
    private func getMethodName(index : Int) -> String{
        let charactersToRemove = NSCharacterSet.alphanumerics.inverted
        let strippedReplacement = self.components(separatedBy: charactersToRemove).joined(separator: "_")
        return "test\(strippedReplacement)_\(index)";
    }
}

//: # Learning Swift by example
/*: # Learn Swift by Example
This is an attempt to teach the Swift Programming Language using itself and being able to execute it as a suite of Tests. The main goals are:

1. It should be easy to read, almost in plain English
2. It should be based in examples
3. Each example should be executable and self-tested

*/
//: ## Constants and variables

"In Swift, we can define a constant by using the keyword let and specifying the type after the declaration".forExample(
    thisCode{
        let constant : String = "Hello"
        return constant
    }.returns{ "Hello" }
)

"Or we can define a variable by using the keyword var".forInstance(
    thisCode{
        var variable : Int = 5
        variable = 7
        return variable
    }.returns{ 7 }
)

"We don't even have to specify the type of a constant or variable since the compiler is able to infer it".i_e(
    thisCode{
        var variable = 5
        variable = 7
        return variable
    }.returns{ 7 }
)

"And crazily, we can name variables and constants with any Unicode characters - even emojis".forInstance(
    thisCode{
        var 👍 = "Success"
        return 👍
    }.returns{
        "Success"
    }
)

//: ## Numeric literals

"We can write integer numbers using decimal, binary, octal or hexadecimal".i_e(
    thisCode{ 17 }.returns{ 17 },
    thisCode{ 0b10001 }.returns{ 17 },
    thisCode{ 0o21 }.returns{ 17 },
    thisCode{ 0x11 }.returns{ 17 }
)

"Also, we can improve readability of numbers by inserting underscores".forInstance(
    thisCode{ 1_000_000 }.returns{ 1000000 }
)

//: ## Operations

"In Swift, we have integer arithmetic operands".forExample(
    thisCode{ 2 + 2 }.returns{ 4 },
    thisCode{ 5 - 8 }.returns{ -3 },
    thisCode{ 4 * 6 }.returns{ 24 },
    thisCode{ 30 / 5 }.returns{ 6 },
    thisCode{ 39 % 7 }.returns{ 4 }
)

"Operators are overloaded. + can concatenate two Strings".forInstance(
    thisCode{ "Hello " + "World" }.returns{ "Hello World" }
)

"...or can add two numbers".i_e(
    thisCode{ 5 + 5 }.returns{ 10 }
)

//: ## String manipulation

"We can interpolate variables into strings".forExample(
    thisCode{
        let salute = "World"
        return "Hello \(salute)"
    }.returns{
        "Hello World"
    },
    thisCode{
        let age = 28
        return "I am \(age) years old"
    }.returns{
        "I am 28 years old"
    }
)

//: ## Optionals

"In Swift, if a variable can receive nil it has to be declared as optional (type followed by question mark) and we need to unwrap it before using it".forInstance(
    thisCode{
        var optional : String? = nil
        if let unwrappedOptional = optional {
            return "Variable had a value"
        }else{
            return "Variable was nil"
        }
    }.returns{
        "Variable was nil"
    },
    
    thisCode{
        var optional : String? = "some value"
        if let unwrappedOptional = optional {
            return "Variable had a value"
        }else{
            return "Variable was nil"
        }
    }.returns{
        "Variable had a value"
    }
)
//: Boilerplate to make the tests work

class PlaygroundTestObserver : NSObject, XCTestObservation {
    @objc func testCase(_ testCase: XCTestCase, didFailWithDescription description: String, inFile filePath: String?, atLine lineNumber: UInt) {
        print("Test failed on line \(lineNumber): \(testCase.name), \(description)")
    }
}

let observer = PlaygroundTestObserver()
let center = XCTestObservationCenter.shared()
center.addTestObserver(observer)

struct TestRunner {
    
    func runTests(testClass:AnyClass) {
        print("Running test suite \(testClass)")
        let tests = testClass as! XCTestCase.Type
        let testSuite = tests.defaultTestSuite()
        testSuite.run()
        let run = testSuite.testRun as! XCTestSuiteRun
        
        print("Ran \(run.executionCount) tests in \(run.testDuration)s with \(run.totalFailureCount) failures")
    }
    
}

//: Run your tests

TestRunner().runTests(testClass: SwiftExamplesTest.self)


