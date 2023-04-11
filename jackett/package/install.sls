# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}
{%- from tplroot ~ "/libtofs.jinja" import files_switch with context %}

Jackett user account is present:
  user.present:
{%- for param, val in jackett.lookup.user.items() %}
{%-   if val is not none and param != "groups" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - usergroup: true
    - createhome: true
    - groups: {{ jackett.lookup.user.groups | json }}
    # (on Debian 11) subuid/subgid are only added automatically for non-system users
    - system: false

Jackett user session is initialized at boot:
  compose.lingering_managed:
    - name: {{ jackett.lookup.user.name }}
    - enable: {{ jackett.install.rootless }}
    - require:
      - user: {{ jackett.lookup.user.name }}

Jackett paths are present:
  file.directory:
    - names:
      - {{ jackett.lookup.paths.base }}
    - user: {{ jackett.lookup.user.name }}
    - group: {{ jackett.lookup.user.name }}
    - makedirs: true
    - require:
      - user: {{ jackett.lookup.user.name }}

{%- if jackett.install.podman_api %}

Jackett podman API is enabled:
  compose.systemd_service_enabled:
    - name: podman.socket
    - user: {{ jackett.lookup.user.name }}
    - require:
      - Jackett user session is initialized at boot

Jackett podman API is available:
  compose.systemd_service_running:
    - name: podman.socket
    - user: {{ jackett.lookup.user.name }}
    - require:
      - Jackett user session is initialized at boot
{%- endif %}

Jackett compose file is managed:
  file.managed:
    - name: {{ jackett.lookup.paths.compose }}
    - source: {{ files_switch(["docker-compose.yml", "docker-compose.yml.j2"],
                              lookup="Jackett compose file is present"
                 )
              }}
    - mode: '0644'
    - user: root
    - group: {{ jackett.lookup.rootgroup }}
    - makedirs: True
    - template: jinja
    - makedirs: true
    - context:
        jackett: {{ jackett | json }}

Jackett is installed:
  compose.installed:
    - name: {{ jackett.lookup.paths.compose }}
{%- for param, val in jackett.lookup.compose.items() %}
{%-   if val is not none and param != "service" %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
{%- for param, val in jackett.lookup.compose.service.items() %}
{%-   if val is not none %}
    - {{ param }}: {{ val }}
{%-   endif %}
{%- endfor %}
    - watch:
      - file: {{ jackett.lookup.paths.compose }}
{%- if jackett.install.rootless %}
    - user: {{ jackett.lookup.user.name }}
    - require:
      - user: {{ jackett.lookup.user.name }}
{%- endif %}

{%- if jackett.install.autoupdate_service is not none %}

Podman autoupdate service is managed for Jackett:
{%-   if jackett.install.rootless %}
  compose.systemd_service_{{ "enabled" if jackett.install.autoupdate_service else "disabled" }}:
    - user: {{ jackett.lookup.user.name }}
{%-   else %}
  service.{{ "enabled" if jackett.install.autoupdate_service else "disabled" }}:
{%-   endif %}
    - name: podman-auto-update.timer
{%- endif %}
