# -*- coding: utf-8 -*-
# vim: ft=sls

{%- set tplroot = tpldir.split('/')[0] %}
{%- set sls_config_clean = tplroot ~ '.config.clean' %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}

include:
  - {{ sls_config_clean }}

{%- if jackett.install.autoupdate_service %}

Podman autoupdate service is disabled for Jackett:
{%-   if jackett.install.rootless %}
  compose.systemd_service_disabled:
    - user: {{ jackett.lookup.user.name }}
{%-   else %}
  service.disabled:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}

Jackett is absent:
  compose.removed:
    - name: {{ jackett.lookup.paths.compose }}
    - volumes: {{ jackett.install.remove_all_data_for_sure }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jackett.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jackett.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
{%- endif %}
    - require:
      - sls: {{ sls_config_clean }}

Jackett compose file is absent:
  file.absent:
    - name: {{ jackett.lookup.paths.compose }}
    - require:
      - Jackett is absent

Jackett user session is not initialized at boot:
  compose.lingering_managed:
    - name: {{ jackett.lookup.user.name }}
    - enable: false
    - onlyif:
      - fun: user.info
        name: {{ jackett.lookup.user.name }}

Jackett user account is absent:
  user.absent:
    - name: {{ jackett.lookup.user.name }}
    - purge: {{ jackett.install.remove_all_data_for_sure }}
    - require:
      - Jackett is absent
    - retry:
        attempts: 5
        interval: 2

{%- if jackett.install.remove_all_data_for_sure %}

Jackett paths are absent:
  file.absent:
    - names:
      - {{ jackett.lookup.paths.base }}
    - require:
      - Jackett is absent
{%- endif %}
