# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_config_file = tplroot ~ ".config.file" %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}

include:
  - {{ sls_config_file }}

Jackett service is enabled:
  compose.enabled:
    - name: {{ jackett.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jackett.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jackett.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
    - require:
      - Jackett is installed
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
{%- endif %}

Jackett service is running:
  compose.running:
    - name: {{ jackett.lookup.paths.compose }}
{%- for param in ["project_name", "container_prefix", "pod_prefix", "separator"] %}
{%-   if jackett.lookup.compose.get(param) is not none %}
    - {{ param }}: {{ jackett.lookup.compose[param] }}
{%-   endif %}
{%- endfor %}
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
{%- endif %}
    - watch:
      - Jackett is installed
      - sls: {{ sls_config_file }}
