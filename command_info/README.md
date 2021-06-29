---
created: 2021-06-29
tags:
    - ansible
---

# A small Ansible module: `command_info`

TL;DR: look ma, I'm writing Python! 

As documented in [an earlier blog entry](/entry/ansible-dream), I 
try to capture the configuration of my environment via Ansible playbooks and
roles. Admittedly overkill, but I have to remain true to my brand.

In those configuration playbooks relating to command-line tools, there is a recurring pattern:
is the tool already installed and at its desired version (or better)? Yes?
Good. No? Then do the install dance. 

The biggest bit of that pattern is retrieving the information as of the
local existence of that command and of its version. Which is not too bad to
retrieve, but not exactly a beauty either:

```yaml
- name: check for installed thingy
  shell: "thingy --version 2>&1 | perl -nE'say $1 if /v(\\d+\\.\\d+\\.\\d+)/'"
  register: installed_thingy
  ignore_errors: true

- name: install new thingy
  when: "installed_thingy.stdout != thingy_version"
  import_tasks: ./install.yml
```

Wouldn't it be better to have that munging be made more generic and hidden
behind a custom module? I'm thinking something like:

```yaml
- name: check for installed thingy
  command_info: 
    command_name: thingy
    target_version: '{{thingy_version}}'
  register: installed_thingy

- name: install new thingy
  when: installed_thingy.needs_upgrade
  import_tasks: ./install.yml
```

Yes? Well, I thought so too. And since Ansible is kind enough to allow writing
modules in any language, I did a [first version of that module in Perl](https://github.com/yanick/dev-env/blob/main/playbooks/library/command_facts):

```perl
#!/usr/bin/env perl

# WANT_JSON
use strict;
no warnings;

use JSON qw/ to_json from_json /;

open my $fh, '<', shift;

my $config = from_json join '', <$fh>;

my $program = $config->{program};
my $args = $config->{version_args};

my %facts = (
    target_version => $config->{target_version}
);

chomp( $facts{location} = `which $program` );

sub numify {
    my $num = 0;

    $num = $num * 1_000 + $_ for $_[0] =~ /(\d+)/g;

    return $num;
}

if( $facts{location} ) {
    ($facts{version}) = `$program $args`;
    chomp $facts{version};
    $facts{version} =~ /([0-9.]+)/;
    $facts{version} = $1 if $1;
    $facts{num_version} = numify($facts{version});
}

$facts{num_version} ||= 0;

$facts{changed} = $facts{version} eq $config->{target_version}
                  ? JSON::false
                  : JSON::true;

$facts{needs_upgrade} = $facts{num_version} 
                            < numify($config->{target_version}) 
                        ? JSON::true 
                        : JSON::false;

print to_json \%facts;
```

And that already works pretty darn swell. But today I was looking at it, and
thought it'd be nice to document that module. 

Alas, it seems that documenting
modules in a way that `ansible-doc` can understand can only be done for Python
code. I... could have tried to fudge my Perl code in a way that it'd look
Pythonish enough for `ansible-doc` and yet still be executable Perl, but eeeeeh,
why not using this as an excuse to try my hand at real, honest to God Python
code? And thus the Perl script became [this](https://github.com/yanick/dev-env/blob/main/plugins/modules/command_info.py):

```python
#!/usr/bin/env python3

# Copyright: (c) 2021, Yanick Champoux <yanick@babyl.ca>
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import absolute_import, division, print_function

__metaclass__ = type

DOCUMENTATION = r"""
---
module: command_info

short_description: Retrieves information about a given command.

version_added: "1.0.0"

description: Retrieves the location and version of a command on 
                the remote machine.

options:
    command_name:
        description: Target command.
        required: true
        type: str

    version_args:
        description: Arguments passed to the command to print 
                        the version string.
        required: false
        default: --version
        type: str

    version_regex:
        description: Regular expression to capture the version from the 
                        command output.
        default: v?(\d+\.\d+\.\d+[^\n ]*)
        required: false
        type: str

    target_version:
        description: Target version to compare against.
        required: false
        type: str

author:
    - Yanick Champoux (@yanick)
"""

EXAMPLES = r"""
- name: perl info
  command_info:
    command_name: perl
    target_version: 5.32.0

# get the info on ls
- name: ls info
  command_info:
    command_name: ls
    version_regex: '(\d+\.d+)'
    target_version: 8.30
"""

RETURN = r"""
needs_upgrade:
    description: Wether the new version of the command needs 
                    to be installed.
    type: bool
    sample: True

installed_version:
    description: Version string of the currently installed command.
    type: str
    sample: '1.2.3'

location:
    description: Path where the command was found.
    type: str
    sample: '/usr/local/bin/ls'
"""

from ansible.module_utils.basic import AnsibleModule
import subprocess
import re
from cmp_version import cmp_version


def run_module():
    module_args = dict(
        command_name=dict(type="str", required=True),
        version_args=dict(default="--version"),
        version_regex=dict(default=r"v?(\d+\.\d+\.\d+[^\n ]*)"),
        target_version=dict(default=None, type="str"),
    )

    result = dict(
        changed=False,
        needs_upgrade=False,
        installed_version=None,
        location=None,
    )

    module = AnsibleModule(
                argument_spec=module_args, 
                supports_check_mode=True
            )

    cmd_location = subprocess.run(
        [
            "which",
            module.params["command_name"],
        ],
        text=True,
        capture_output=True,
    )

    result["location"] = cmd_location.stdout.rstrip()

    if result["location"]:
        cmd_output = subprocess.run(
            [module.params["command_name"], module.params["version_args"]],
            capture_output=True,
            text=True,
        )

        result["command_stdout"] = cmd_output.stdout
        result["command_stderr"] = cmd_output.stderr

        m = re.search(
            module.params["version_regex"],
            result["command_stdout"] + result["command_stderr"],
        )

        if m:
            result["installed_version"] = m.group(1)

    if "target_version" in module.params:
        result["needs_upgrade"] = 1 == cmp_version(
            module.params["target_version"], result["installed_version"]
        )

    module.exit_json(**result)


def main():
    run_module()


if __name__ == "__main__":
    main()
```


What would you know, it actually works. And `ansible-doc` approves of it too!

```bash

⥼ ansible-doc -t module command_info
> COMMAND_INFO    (/home/yanick/work/dev-env/plugins/modules/command_info.py)

        Retrieves the location and version of a command on the remote
        machine.

  * This module is maintained by The Ansible Community
OPTIONS (= is mandatory):

= command_name
        Target command.

        type: str

- target_version
        Target version to compare against.
        [Default: (null)]
        type: str

- version_args
        Arguments passed to the command to print the version string.
        [Default: --version]
        type: str

- version_regex
        Regular expression to capture the version from the command
        output.
        [Default: v?(\d+\.\d+\.\d+[^\n ]*)]
        type: str


AUTHOR: Yanick Champoux (@yanick)
        METADATA:
          status:
          - preview
          supported_by: community
        

EXAMPLES:

- name: perl info
  command_info:
    command_name: perl
    target_version: 5.32.0

# get the info on ls
- name: ls info
  command_info:
    command_name: ls
    version_regex: '(\d+\.d+)'
    target_version: 8.30


RETURN VALUES:

needs_upgrade:
    description: Wether the new version of the command needs to be installed.
    type: bool
    sample: True

installed_version:
    description: Version string of the currently installed command.
    type: str
    sample: '1.2.3'

location:
    description: Path where the command was found.
    type: str
    sample: '/usr/local/bin/ls'

```


