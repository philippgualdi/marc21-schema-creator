"""MARC21 field mapping."""

from dojson import Overdo
from dojson import utils

marc21 = Overdo()

{%- for tag, field in data if tag|length() == 3 %}
{%- if 'subfields' in field %}

{%- set indicator1 = get_indicator(1, field) %}
{%- set indicator2 = get_indicator(2, field) %}

@marc21.over('{{ clean_name(field.name) }}', '^{{ tag }}{{ indicator1['re'] }}{{ indicator2['re'] }}')
{%- if field.repeatable %}
@utils.for_each_value
{%- endif %}
@utils.filter_values
def {{ clean_name(field.name) }}(self, key, value):
    {%- if indicator1.get('name') %}
    indicator_map1 = {{ indicator1.get('values', {}) }}
    {%- endif %}
    {%- if indicator2.get('name') %}
    indicator_map2 = {{ indicator2.get('values', {}) }}
    {%- endif %}
    return {
    {%- for code, subfield in field.get('subfields').iteritems() %}
        '{{ clean_name(subfield['name']) }}': value.get('{{ code }}'),
    {%- endfor %}
    {%- if indicator1.get('name') %}
        '{{ indicator1['name'] }}': indicator_map1.get(key[3]),
    {%- endif %}
    {%- if indicator2.get('name') %}
        '{{ indicator2['name'] }}': indicator_map2.get(key[4]),
    {%- endif %}
    }
{%- else %}

@marc21.over('{{ clean_name(field.name) }}', '^{{ tag }}')
def {{ clean_name(field.name) }}(self, key, value):
    return value[0]
{%- endif %}
{%- endfor %}
