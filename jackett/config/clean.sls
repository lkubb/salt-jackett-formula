# vim: ft=sls

{#-
    Removes the configuration of the jackett containers
    and has a dependency on `jackett.service.clean`_.

    This does not lead to the containers/services being rebuilt
    and thus differs from the usual behavior.
#}

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_service_clean = tplroot ~ ".service.clean" %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}

include:
  - {{ sls_service_clean }}

Jackett environment files are absent:
  file.absent:
    - names:
      - {{ jackett.lookup.paths.config_jackett }}
      - {{ jackett.lookup.paths.base | path_join(".saltcache.yml") }}
    - require:
      - sls: {{ sls_service_clean }}
