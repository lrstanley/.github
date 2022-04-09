<p align="center">{{ repo.name }}{% if repo.description %} -- {{ repo.description }}{% endif %}</p>
<p align="center">
{%- if latest_release|length > 0 %}
  <a href="{{ repo.html_url }}/releases">
    <img alt="Release Downloads" src="https://img.shields.io/github/downloads/{{ repo.full_name }}/total?style=flat-square">
  </a>
{%- endif %}
{%- if repo.license %}
  <a href="{{ repo.html_url }}/blob/{{ repo.default_branch }}/LICENSE">
    <img alt="Software License" src="https://img.shields.io/github/license/{{ repo.full_name }}?style=flat-square">
  </a>
{%- endif %}
{%- for workflow in workflows %}
{%- if "build" in workflow.name || "release" in workflow.name || "test" in workflow.name %}
  <a href="{{ repo.html_url }}/actions?query=workflow%3A{{ workflow.name }}+event%3Apush">
    <img alt="GitHub Workflow Status ({{ workflow.name }} @ {{ repo.default_branch }})" src="https://img.shields.io/github/workflow/status/{{ repo.full_name }}/{{ workflow.name }}/{{ repo.default_branch }}?label={{ workflow.name|urlencode }}&style=flat-square&event=push">
  </a>
{%- endif %}
{% endfor -%}
{%- if language_count > 0 %}
  <img alt="Code Coverage" src="https://img.shields.io/codecov/c/github/{{ repo.full_name }}/{{ repo.default_branch }}?style=flat-square">
{% endif -%}
{%- if repo.has_issues %}
  <img alt="Bug reports" src="https://img.shields.io/github/issues/{{ repo.full_name }}/bug?label=issues&style=flat-square">
  <img alt="Feature requests" src="https://img.shields.io/github/issues/{{ repo.full_name }}/enhancement?label=feature%20requests&style=flat-square">
{%- endif %}
  <a href="{{ repo.html_url }}/pulls">
    <img alt="Open Pull Requests" src="https://img.shields.io/github/issues-pr/{{ repo.full_name }}?style=flat-square">
  </a>
{%- if latest_release|length > 0 %}
  <a href="{{ repo.html_url }}/releases">
    <img alt="Latest Semver Release" src="https://img.shields.io/github/v/release/{{ repo.full_name }}?style=flat-square">
    <img alt="Latest Release Date" src="https://img.shields.io/github/release-date/{{ repo.full_name }}?style=flat-square">
  </a>
{%- else %}
  <a href="{{ repo.html_url }}/tags">
    <img alt="Latest Semver Tag" src="https://img.shields.io/github/v/tag/{{ repo.full_name }}?style=flat-square">
  </a>
{%- endif %}
  <img alt="Last commit" src="https://img.shields.io/github/last-commit/{{ repo.full_name }}?style=flat-square">
  <a href="{{ repo.html_url }}/discussions/new?category=q-a">
    <img alt="Ask a Question" src="https://img.shields.io/badge/Discussions-Ask_a_Question!-green?style=flat-square">
  </a>

  <a href="https://liam.sh/chat"><img src="https://img.shields.io/badge/discord-bytecord-blue.svg" alt="Discord Chat"></a>
</p>
