---
created: 2018-05-24
tags:
    - javascript
    - redux
---

# Reduce and Conquer

In an ecosystem riddled with large, portentous frameworks, [Redux][] is a refreshingly ascetic little store management system.
Driven more by its functional programming-inspired tenets than supporting code, it offers 
— and needs — only 
a few helper functions to manage its stores.

Minimalism is good. It's also a good idea to abstract oft-used patterns 
into more expressive forms. Ideally, code should be crafted such that its
intent comes out on first read, while making deeper digs possible when required.

Happily enough, the judicious use of delightfully succinct higher-order functions is often all that's
required to tailor-suit some ergonomics into the manipulation of middleware and reducers. 
This blog entry will showcase some of those helper functions that work for me.

This article assumes you're already familiar with Redux. If this isn't the case, you might
want to check out first one of my [previous articles][pollux], which provides
a gentler, if a tad unconventional, introduction to the framework.

*read the full blog entry at the [Infinity Interactive
Notebook](https://iinteractive.com/notebook/2018/05/24/reduce-and-conquer.html)*

[Redux]:            https://redux.js.org/
[binding operator]: https://github.com/tc39/proposal-bind-operator
[lodash]:           https://lodash.com/
[lodash/fp]:        https://github.com/lodash/lodash/wiki/FP-Guide
[pet project]:      http://techblog.babyl.ca/entry/javascript-of-the-darkest-sea
[sagas]:            https://github.com/redux-saga/redux-saga
[updeep]:           https://github.com/substantial/updeep
[pollux]:           https://www.iinteractive.com/notebook/2016/09/09/pollux.html
