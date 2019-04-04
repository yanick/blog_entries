---
created: 2015-10-12
---

# A Call to All Dancer2 Plugin Writers

*Was original a message to the [dancer-user mailing list](http://lists.preshweb.co.uk/pipermail/dancer-users/2015-October/005165.html).  Reproduced here for the signal boost. And because, hey, why not?*

*Edit:* added the points brought by Racke in a reply to the original mailing
list message.


Underneath the surface, I've been toiling away at a new plugin system
for Dancer2. This new system aims at fixing a few of the thorny issues
of the current one, and add a wee bit of unicorn dust to the mix.

For plugin users, the changes are:

* No change! The new plugins will be called the same way as the old ones -- it'll be transparent to you if a plugin is new gen or old gen. Isn't that music to your ears, or what? 

* No change! Plugins using the new system can work side-by-side with original plugins. It's all really transparent to you.  Relax, we're taking care of everything. 

For plugin writers, the changes are:

* The new system inherit from Dancer2::Plugin2 (yes, I know, we just loooove that '2' digit around here...).

* The new system is much more OO-based, which so far makes for cleaner, easier to write plugins.

* The new system doesn't export the Dancer keywords into the plugin namespace. It removes a little bit of the sugar (you'll have to do `$self->app->request` instead of `request()` inside the plugin module), but it makes much more explicit what is the plugin class, and what is the plugin instance associated with an app.

* Plugin can now use other plugins!

* The list of plugin instances are also kept as an attribute in the app object, which makes introspection possible (a plugin, for example, can check if other plugin A is already loaded or not and do things in consequence).


* Plugins based on Plugin2 cannot use plugins based on Plugin(1).

## What do I want from you?

Before unleashing D2::P2, it needs to be tested. Racke already [migrated
two plugins to D2::P2](https://github.com/PerlDancer/Dancer2/wiki/Plugins-migrated-to-D2::P2).
I would like for all of you to try to migrate your plugins, and report
if it was a success, or if you uncovered some sore points.

How to do that? I'm glad you asked:

1. clone and use the [Dancer2 branch](https://github.com/yanick/Dancer2/tree/plugins-yanick)

2. read the D2::P2 docs (`perldoc lib/Dancer2/Plugin2`)

3. if docs are not sufficient, check examples (`/t/plugins2-*`) and the already-ported modules at bullet #5 below.

4. report all problems, head-scratchers, suggestions, etc to [the D2::P2 PR](https://github.com/PerlDancer/Dancer2/pull/1010#issuecomment-147376270)

5. you ported the plugin and all works? Post your victory to the PR dicussion
at #4, and add your plugin to [the
list](https://github.com/PerlDancer/Dancer2/wiki/Plugins-migrated-to-D2::P2).  That's important, I'll set up a job to test any new tweaks on 	D2::P2 to all the converted modules)

And, of course, you have questions or anything, please feel free to hit
me with'em.
