===========
git-irebase
===========


Overview
========

``git-irebase`` can be installed and used by anybody to replace ``git-rebase``
on a branch.

  ``irebase`` for incremental rebase. So instead rebasing your patches to 
  the new ref of your tracked branch, it'll make sure the rebase is incrementally
  done on each new commit of the tracked branch.
  This ensures that you'll individualise and identify smallest conflict possible.
  And some conflict scenario are suceptible to be resolved automatically.

``irebase-manager`` is intended to be executed on a server (can be indenpendant)
on a regular basis (with cron). It'll perform a ``git-irebase`` on a list of
repositories and branches.

  This script is intended to be executed on an instance that will run periodically
  and warn you when it can't rebase automatically to the target branch. It also
  take care to push back the reference.


Maturity
========

This code is in alpha stage. Provided only for sharing ideas.


Dependencies
============

Both requires the `kal-shlib-pretty`_ package.

.. _kal-shlib-pretty: https://github.com/vaab/kal-shlib-pretty

``git-irebase`` doesn't have much more dependency than ``bash`` and ``git``.

``irebase-manager`` requires ``shyaml`` to be installed.


Config file
===========

The config file is only for ``irebase-manager``. It is located in ``/etc/irebase-manager.rc``.
It uses ``yaml``.

For example::

    work-dir: /srv/irebase-manager
    send-report:
      mail:
        recipients:
          - valentin.lab_irebase-manager@kalysto.org
      slack:
        slackaccountlabel:
          token: "xoxb-3381751679-gtdywBrfpwHasWcfBjwQqfFF"
          msg:
            success:
              - to: ["#irebase"]
                body: >
                  rebased ${patchpile_count}c of $walking_branch onto
                  new ${revlist_count}c of $target_branch.
            failure:
              - to: [vlab, "#irebase"]
                body: >
                  I'm afraid I'll need some help on this. Can you push back on
                  repository $walking_repos the branch $walking_branch after solving
                  the conflict I've faced ?

                  Don't forget to get the last version of the branches:

                      git fetch "$target_repos" "$target_branch"
                      git branch "$target_branch" FETCH_HEAD -f
                      git fetch "$walking_repos" "$walking_branch"
                      git branch "$walking_branch" FETCH_HEAD -f
                      git checkout "$walking_branch"
                      git rebase $target_branch

                  $report

                  Many thanks.

      irebase:
        odoo:
          - walking-branch:
              branch-name: 0k/8.0-odoo-auto-rebase
              repository: /var/git/0k/odoo.git
            target-branch:
              branch-name: 8.0
              repository: https://github.com/odoo/odoo.git
          - walking-branch:
              branch-name: 0k/8.0-ocb-auto-rebase
              repository: /var/git/0k/odoo.git
            target-target:
              branch-name: 8.0
              repository: https://github.com/oca/ocb.git


Install
=======

- Install Dependencies first.
- clone this repository
- link ``git-irebase`` to use it as a normal command::

    ln -sf $MYPATH/bin/git-irebase /usr/lib/git-core/

- you may want to put ``irebase-manager`` in you ``$PATH``,
  so you could::

    ln -sf $MYPATH/bin/irebase-manager /usr/local/bin/

You are done.


Usage
=====

You can launch ``irebase-manager``::

    irebase-manager [--send-report MYPATH]

The send-report must be an executable that we receive several
environment variable and some stdin report from ``git-irebase``.
This script job is to send it by any means toward who should
receive it.

If not specified, ``mail`` system command is used.

A slacker executable is provided in
``share/git-irebase/send-report/slack`` and will use the configuration
store in ``/etc/irebase-manager.rc``.


Todo
====

- a real doc.
- test should be easily hookable to rebase to stop when test fails
- slack message interface example
- should look at ``git imerge``


Push Request Guidelines
-----------------------

You can send any code. I'll look at it and will integrate it myself in
the code base and leave you as the author. This process can take time and
it'll take less time if you follow the following guidelines:

- separate your commits per smallest concern.
- each commit should pass the tests (to allow easy bisect)
- each functionality/bugfix commit should contain the code, tests,
  and doc.
- prior minor commit with typographic or code cosmetic changes are
  very welcome. These should be tagged in their commit summary with
  ``!minor``.
- the commit message should follow gitchangelog rules (check the git
  log to get examples)
- if the commit fixes an issue or finished the implementation of a
  feature, please mention it in the summary.

If you have some questions about guidelines which is not answered here,
please check the current ``git log``, you might find previous commit that
would show you how to deal with your issue.


License
=======

Copyright (c) 2015 Valentin Lab.

Licensed under the `BSD License`_.

.. _BSD License: http://raw.github.com/0k/git-irebase/master/LICENSE
