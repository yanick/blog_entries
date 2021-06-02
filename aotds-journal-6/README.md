---
title: AotDS, captain log 6
created: 2021-01-20
tags:
    - aotds
    - microblog
---

<div class="h-entry">
<div class="e-content">

<span style="display: none">#aotds, captain log 6:</span> A quick pause of the glamour of the UI. I'm taking a moment
to throw in some functionality to [my fork of updeep](https://www.npmjs.com/package/@yanick/updeep).

</div>
<a class="u-in-reply-to" href="https://twitter.com/yenzie/status/1350901089449742336"></a>
</div>

From now on, `u.if` mostly uses lodash's `matches` for its predicate, and
there are two new function, `u.mapWhen` and `u.mapWhenElse` for extra 
array manipulation goodness.

For example, altering weapon orders that already exist
or create a new one if they don't, will be able to switch from

```js
$store = u({
  bogeys: u.map(
    u.if(
      fp.matches({id: bogey_id}),
      u.updateIn('orders.weapons',
        weapons => [
            ...fp.reject({weapon_id}, weapons),
            {firecon_id, weapon_id}
        ]
      )
    )
)}, $store);
```

to

```js
$store = u({
  bogeys: u.mapWhen(
    {id: bogey_id},
    u.updateIn('orders.weapons',
      u.mapWhenElse(
        {weapon_id}, {firecon_id}, { weapon_id, firecon_id }
      )
    )
  )
}, $store);
```

Still not for the faint of heart. But then, neither is the darkest sea.
