# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}

jackett service is dead:
  compose.dead:
    - name: {{ jackett.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jackett.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jackett.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
{%- endif %}

jackett service is disabled:
  compose.disabled:
    - name: {{ jackett.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jackett.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jackett.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
{%- endif %}
