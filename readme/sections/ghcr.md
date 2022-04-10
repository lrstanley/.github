{% if ghcr|length > 0 -%}
### :whale: Container Images (ghcr)

```console
{%- for container in ghcr %}
{%- for tag in container.tags|sorted %}
$ docker run -it --rm ghcr.io/{{ container.user }}/{{ container.name }}:{{tag}}
{%- endfor %}
{%- endfor %}
```
{%- endif %}
