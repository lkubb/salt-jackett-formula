# vim: ft=sls

{%- set tplroot = tpldir.split("/")[0] %}
{%- set sls_package_install = tplroot ~ ".package.install" %}
{%- from tplroot ~ "/map.jinja" import mapdata as jackett with context %}
{%- from tplroot ~ "/libtofsstack.jinja" import files_switch with context %}

include:
  - {{ sls_package_install }}

Jackett environment files are managed:
  file.managed:
    - names:
      - {{ jackett.lookup.paths.config_jackett }}:
        - source: {{ files_switch(
                        ["jackett.env", "jackett.env.j2"],
                        config=jackett,
                        lookup="jackett environment file is managed",
                        indent_width=10,
                     )
                  }}
    - mode: '0640'
    - user: root
    - group: {{ jackett.lookup.user.name }}
    - makedirs: true
    - template: jinja
    - require:
      - user: {{ jackett.lookup.user.name }}
    - watch_in:
      - Jackett is installed
    - context:
        jackett: {{ jackett | json }}

Jackett config file is managed:
  file.serialize:
    - name: {{ jackett.lookup.paths.data | path_join("Jackett", "ServerConfig.json") }}
    - serializer: json
    - merge_if_exists: true
    - mode: '0644'
    - user: {{ jackett.lookup.user.name }}
    - group: {{ jackett.lookup.user.name }}
    - makedirs: True
    - template: jinja
    - require:
      - user: {{ jackett.lookup.user.name }}
    - watch_in:
      - Jackett is installed
    - dataset: {{ jackett.config.general | json }}

# There are also tracker-specific config files in `Jackett/Indexers/<>.json`.
