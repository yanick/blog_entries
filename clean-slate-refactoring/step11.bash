$ git show --compact-summary :/wip-clean-slate
commit 68d13c32d97ad3de24dedf6a2cc4cb3075d0ef13 (HEAD -> js-rewrite)
Author: Yanick Champoux <yanick@babyl.ca>
Date:   Wed Sep 29 14:06:53 2021 -0400

    wip-clean-slate

 README.md (gone)                        | 138 --------------------------------------
 dist/cli.js (gone)                      |   8 ---
 dist/colors.js (gone)                   |  12 ----
 dist/command.js (gone)                  |  38 -----------
 dist/commands/info.js (gone)            |  39 -----------
 dist/commands/install.js (gone)         |  56 ----------------
 dist/commands/run.js (gone)             |  31 ---------
 dist/commands/run.test.js (gone)        |  16 -----
 dist/hook.js (gone)                     |  67 ------------------
 dist/hook.test.js (gone)                |  12 ----
 dist/index.js (gone)                    |   8 ---
 dist/vaudeville.js (gone)               |  68 -------------------
 jest.config.js (gone)                   |   9 ---
 package.json (gone)                     |  55 ---------------
 src/@types/simple-git/index.d.ts (gone) |   3 -
 src/@types/yurnalist/index.d.ts (gone)  |   4 --
 src/cli.ts (gone)                       |   6 --
 src/colors.ts (gone)                    |  23 -------
 src/command.ts (gone)                   |  40 -----------
 src/commands/info.ts (gone)             |  43 ------------
 src/commands/install.ts (gone)          |  72 --------------------
 src/commands/run.test.ts (gone)         |  16 -----
 src/commands/run.ts (gone)              |  50 --------------
 src/hook.test.ts (gone)                 |   7 --
 src/hook.ts (gone)                      | 127 -----------------------------------
 src/index.ts (gone)                     |   2 -
 src/vaudeville.ts (gone)                |  91 -------------------------
 tsconfig.json (gone)                    |  66 ------------------
 28 files changed, 1107 deletions(-)

$ ls -a
.git  .gitignore  Changes
