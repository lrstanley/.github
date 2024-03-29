{%- if not options.nodescription %}
<p align="center">{{ repo.name }}{% if repo.description %} -- {{ repo.description }}{% endif %}</p>
{%- endif %}
<p align="center">
{%- if latest_release|length > 0 %}
  <a href="{{ repo.html_url }}/releases">
    <img title="Release Downloads" src="https://img.shields.io/github/downloads/{{ repo.full_name }}/total?style=flat-square">
  </a>
{%- endif %}
  <a href="{{ repo.html_url }}/tags">
    <img title="Latest Semver Tag" src="https://img.shields.io/github/v/tag/{{ repo.full_name }}?style=flat-square">
  </a>
  <a href="{{ repo.html_url }}/commits/{{ repo.default_branch }}">
    <img title="Last commit" src="https://img.shields.io/github/last-commit/{{ repo.full_name }}?style=flat-square">
  </a>
{%- for workflow in workflows %}
{%- if "build" in workflow.name || "test" in workflow.name %}
  <a href="{{ repo.html_url }}/actions?query=workflow%3A{{ workflow.name }}+event%3Apush">
    <img title="GitHub Workflow Status ({{ workflow.name }} @ {{ repo.default_branch }})" src="https://img.shields.io/github/actions/workflow/status/{{ repo.full_name }}/{{ workflow.name }}.yml?branch={{ repo.default_branch }}&label={{ workflow.name|urlencode }}&style=flat-square">
  </a>
{%- endif %}
{% endfor -%}
{%- if language_count > 0 %}
  <a href="https://codecov.io/gh/{{ repo.full_name }}">
    <img title="Code Coverage" src="https://img.shields.io/codecov/c/github/{{ repo.full_name }}/{{ repo.default_branch }}?style=flat-square">
  </a>
{% endif -%}
{%- if "Go" in languages && env.GO_MODULE %}
  <a href="https://pkg.go.dev/{{ env.GO_MODULE }}">
    <img title="Go Documentation" src="https://pkg.go.dev/badge/{{ env.GO_MODULE }}?style=flat-square">
  </a>
  <a href="https://goreportcard.com/report/{{ env.GO_MODULE }}">
    <img title="Go Report Card" src="https://goreportcard.com/badge/{{ env.GO_MODULE }}?style=flat-square">
  </a>
{%- endif %}
</p>
<p align="center">
{%- if repo.has_issues %}
  <a href="{{ repo.html_url }}/issues?q=is:open+is:issue+label:bug">
    <img title="Bug reports" src="https://img.shields.io/github/issues/{{ repo.full_name }}/bug?label=issues&style=flat-square">
  </a>
  <a href="{{ repo.html_url }}/issues?q=is:open+is:issue+label:enhancement">
    <img title="Feature requests" src="https://img.shields.io/github/issues/{{ repo.full_name }}/enhancement?label=feature%20requests&style=flat-square">
  </a>
{%- endif %}
  <a href="{{ repo.html_url }}/pulls">
    <img title="Open Pull Requests" src="https://img.shields.io/github/issues-pr/{{ repo.full_name }}?label=prs&style=flat-square">
  </a>
{%- if latest_release|length > 0 %}
  <a href="{{ repo.html_url }}/releases">
    <img title="Latest Semver Release" src="https://img.shields.io/github/v/release/{{ repo.full_name }}?style=flat-square">
    <img title="Latest Release Date" src="https://img.shields.io/github/release-date/{{ repo.full_name }}?label=date&style=flat-square">
  </a>
{%- endif %}
  <a href="{{ repo.html_url }}/discussions/new?category=q-a">
    <img title="Ask a Question" src="https://img.shields.io/badge/support-ask_a_question!-blue?style=flat-square">
  </a>
  <a href="https://liam.sh/chat"><img src="https://img.shields.io/badge/discord-bytecord-blue.svg?style=flat-square" title="Discord Chat"></a>
</p>
