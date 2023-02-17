# vim: ft=sls

{#-
    Starts the jackett container services
    and enables them at boot time.
    Has a dependency on `jackett.config`_.
#}

include:
  - .running
