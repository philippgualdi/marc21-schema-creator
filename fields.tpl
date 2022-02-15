{%- for tag, field in data if tag|length() == 3 %}

{{ clean_name(field.name) }}:
    """TODO."""
    schema:
        {'{{ clean_name(field.name) }}': {'type': '{{ 'list' if field.repeatable else 'dict' }}'}}
{%- endfor %}
