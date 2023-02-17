# vim: ft=sls

{#-
    *Meta-state*.

    Undoes everything performed in the ``jackett`` meta-state
    in reverse order, i.e. stops the jackett services,
    removes their configuration and then removes their containers.
#}

include:
  - .service.clean
  - .config.clean
  - .package.clean
