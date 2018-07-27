# Learning Swift By Example

I have been practicing Swift for some time now and I think I have got a good taste of many of its features. Then, some time ago, I found this [gist][1] that uses Ruby to present examples to learn Ruby in an uncommon way. It is based on the following premises:

1. It should be based on examples
2. Examples should be easy to read, almost in plain English
3. Each example should be able to run as a test

With that in mind, I decided to try to do a similar thing in Swift. Basically, an example like this could read something like:

```swift
"In Swift, we have integer arithmetic operands".forExample(
    thisCode{ 2 + 2 }.returns{ 4 },
    thisCode{ 5 - 8 }.returns{ -3 },
    thisCode{ 4 * 6 }.returns{ 24 },
    thisCode{ 30 / 5 }.returns{ 6 },
    thisCode{ 39 % 7 }.returns{ 4 }
)
```

You can find the whole implementation as a Playground in this repository. Of course, you are welcome to fork it and suggest improvements. In this post, I will try to explain the main features of the language that allowed my to do this. Let's get started!

## Closures and Generics

First thing I tried to accomplish was to model examples as objects in the language. Since I want to run each example as a test, it would have to have two parts which, when executed, will be the two arguments of an assertion.

Each of the two parts of the examples are based on code so, how could I pass code to an object? The answer to this issue is to have **closures** as fields in the object. In this way, I can store the two closures and execute them when the test runs.

However, what should be the type of the closure? Since the example is self-contained, the closure should not receive any parameters, but it can return anything. In that case, it seems that the most suitable thing we can return is a **generic** type. Nevertheless, in the end we need to compare the execution of both closures is equal, so the returned type should be `Equatable`.

Therefore, I managed to create the `SwiftExample<T : Equatable>` class:

```swift
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
```

## Higher order functions

We are going to need to create examples, but calling the constructor every time that we write an example would not look like *writing in plain English*, so I decided to add some sugar to it.

To be able to do this, I used **higher order functions**. Basically, a higher order function is a function that can take another function as a parameter. This is possible thanks to the fact that functions are first order citizens in Swift. Thus, I created the `thisCode` function to help me create examples, receiving the first half of the example as a closure:

```swift
func thisCode<T>(code : @escaping () -> T) -> SwiftExample<T>{
    return SwiftExample<T>(code: code)
}
```

## Method swizzling

Since I want to run examples as tests, I created the `SwiftExamplesTest` class extending the base class for unit testing in Swift. However, I don't know beforehand how many tests I am going to have, and I don't want to remember to add a test every time I add an example.

How can I solve that then? The answer is **method swizzling**. Basically, with method swizzling you can add methods to a class or replace the implementation of existing ones. Hence, every time I have a new example, I would like to add a method to the `SwiftExamplesTest` class to run and test it.

This was actually the hardest part to accomplish but I finally managed to make it work with the following code:

```swift
class SwiftExamplesTest : XCTestCase{
    class func addTestForExample<T>(example : SwiftExample<T>, withName name : String){
        let testToRun = { example.runExample() }
        let implementation = imp_implementationWithBlock(unsafeBitCast(testToRun as @convention(block) () -> (), to: AnyObject.self))
        let methodName = Selector(name)
        let types = "v@:"
        class_addMethod(self, methodName, implementation, types)
    }
}
```

## Extensions

Finally, I want to introduce each example with a small text explaining each language feature, followed by the code that shows it. In order to be able to put it all together, I decided to use **extensions**. This feature enables to extend any class (or even protocols) with functionality that it is lacking.

In this case, the `String` class does not properly *lacks* what I need, but this feature helps my needs pretty well, so I did the following:

```swift
extension String {
	private func forExample<T>(_ examples : [SwiftExample<T>]){
        for (index, example) in examples.enumerated(){
            let methodName = getMethodName(index: index);
            SwiftExamplesTest.addTestForExample(example: example, withName: methodName)
        }
    }
}
```

As you can see, what this extension does is to use the previously defined class method to add a new test for each example that is added. Notice that we can have a variable number of examples.

## Testing in a Playground

Running unit tests is not enabled by default in a Playground, which is something that I was missing until I found this [blog post][2] that proves how to run unit tests with a little bit of boilerplate (which I am not reproducing here, you can check either the post or the playground).

## Limitations

Although the current implementation is pretty powerful, it still has some limitations:

1. Examples under the same rationale must return the same type. The reason behind this is that functions accepting a variable number of arguments represent them as an Array, and in Swift they must be homogeneous.
2. Closures with more than one line of code must explicitly call return. That is something that hinders a little bit the readability of the examples and add a bit of redundancy, but I guess it is not a big deal.

## Conclusion

This little experiment shows the power Swift has to build a **Domain-Specific Language** (DSL) in a few lines of code. I didn't even had to use features like **operator overloading** or **protocol extensions**, which gives you a lot of freedom to extend existing things to match your needs.

 [1]: https://gist.github.com/raul/544948
 [2]: http://initwithstyle.net/2015/11/tdd-in-swift-playgrounds/
 [3]: https://github.com/truizlop/LearningSwiftByExample
 [4]: #
 [5]: #
 [6]: #
 [7]: #
 [8]: #
 [9]: #
 [10]: #
