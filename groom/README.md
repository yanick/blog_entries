---
created: 2016-04-28
---

# Groom That Yak

Here's a super quick one. 

So, for giggles I'm learning Swift. And for practice, I'm using 
[exercism.io](http://exercism.io). A few hours ago, I wrote my first
test and stuff:

```xml
$ swiftc *.swift; and ./main 
Test Suite 'All tests' started at 00:22:13.561
Test Suite 'hamming.xctest' started at 00:22:13.562
Test Suite 'HammingTest' started at 00:22:13.562
Test Case 'HammingTest.testNoDifferenceBetweenEmptyStrands' started at 00:22:13.562
Test Case 'HammingTest.testNoDifferenceBetweenEmptyStrands' passed (0.0 seconds).
Test Case 'HammingTest.testNoDifferenceBetweenIdenticalStrands' started at 00:22:13.562
Test Case 'HammingTest.testNoDifferenceBetweenIdenticalStrands' passed (0.0 seconds).
Test Case 'HammingTest.testCompleteHammingDistanceInSmallStrand' started at 00:22:13.563
Test Case 'HammingTest.testCompleteHammingDistanceInSmallStrand' passed (0.0 seconds).
Test Case 'HammingTest.testSmallHammingDistanceInMiddleSomewhere' started at 00:22:13.563
Test Case 'HammingTest.testSmallHammingDistanceInMiddleSomewhere' passed (0.0 seconds).
Test Case 'HammingTest.testLargerDistance' started at 00:22:13.563
Test Case 'HammingTest.testLargerDistance' passed (0.0 seconds).
Test Case 'HammingTest.testReturnsNilWhenOtherStrandLonger' started at 00:22:13.563
HammingTest.swift:39: error: HammingTest.testReturnsNilWhenOtherStrandLonger : XCTAssertNil failed: "1" - Different length strands return nil
Test Case 'HammingTest.testReturnsNilWhenOtherStrandLonger' failed (0.0 seconds).
Test Case 'HammingTest.testReturnsNilWhenOriginalStrandLonger' started at 00:22:13.563
HammingTest.swift:44: error: HammingTest.testReturnsNilWhenOriginalStrandLonger : XCTAssertNil failed: "1" - Different length strands return nil
Test Case 'HammingTest.testReturnsNilWhenOriginalStrandLonger' failed (0.0 seconds).
Test Suite 'HammingTest' failed at 00:22:13.563
        Executed 7 tests, with 2 failures (0 unexpected) in 0.0 (0.0) seconds
Test Suite 'hamming.xctest' failed at 00:22:13.563
        Executed 7 tests, with 2 failures (0 unexpected) in 0.0 (0.0) seconds
Test Suite 'All tests' failed at 00:22:13.563
        Executed 7 tests, with 2 failures (0 unexpected) in 0.0 (0.0) seconds
```

That's fine, but holy wall of text, Batman... It's not the worst thing I ever
had to peer at (I'm looking at you, all and every java logging system ever
conceived), but it's still not the most readable thing ever.

So... I'm probably re-inventing a perfectly fine wheel existing somewhere else
(and if I am, please enlight me in the comment section), but I blurped a quick 
tool called
[groom](https://github.com/yanick/environment/blob/master/bin/groom). The
idea is to define regexes in a config file to act on lines that I have
colored or altered.

For example, for those Swift test results I created the following `groom.yaml` rule file.

```yaml
# show the testcase names in glorious green
- 
    "^Test Case":
        eval: |
            s/(?<=')([^']+)/colored [ 'green' ], $1 /e;
        fallthrough: 1
# remove the 'started' lines altogether
- started: 
    eval: $_ = ''
# victory or defeat, unicoded and colored
- passed: 
    color: blue
    only_match: 1
    eval: s/^/✔ /
- failed: 
    color: red
    only_match: 1
    eval: s/^/❌ /
# final lines underlined for emphasis
-
    "^\s+Executed": rgb202 underline
```

Which gives me

![groomed screenshot](__ENTRY_DIR__/swift.png)

Purty, eh?
