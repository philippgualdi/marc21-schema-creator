# -*- coding: utf-8 -*-
#
# This file is part of DoJSON
# Copyright (C) 2015, 2016 CERN.
#
# DoJSON is free software; you can redistribute it and/or
# modify it under the terms of the Revised BSD License; see LICENSE
# file for more details.

"""MARC 21 model definition."""

from dojson import utils

from ..model import marc21

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
    """{{ field.name }}."""
    {%- if indicator1.get('name') %}
      {%- if indicator1.get('name') == 'nonfiling_characters' %}
    indicator_map1 = {str(x): str(x) for x in range(10)}
      {%- else %}
    indicator_map1 = {{ tojson(indicator1.get('values', {})) }}
      {%- endif -%}
    {%- endif %}
    {%- if indicator2.get('name') %}
      {%- if indicator2.get('name') == 'nonfiling_characters' %}
    indicator_map2 = {str(x): str(x) for x in range(10)}
      {%- else %}
    indicator_map2 = {{ tojson(indicator2.get('values', {})) }}
      {%- endif -%}
    {%- endif %}

    {%- set reverse_subfields = dict() %}
    field_map = {
      {%- for code, subfield in field.get('subfields').items() %}
        '{{ code }}': '{{ clean_name(subfield['name']) }}',
        {%- do reverse_subfields.update({clean_name(subfield['name']): code}) %}
      {%- endfor %}
    }

    order = utils.map_order(field_map, value)

    {%- if indicator1.get('name') %}

    if key[3] in indicator_map1
      {%- if indicator1.get('name') in reverse_subfields.keys() -%}
      {{ " " }}and '{{ reverse_subfields.get(indicator1.get('name')) }}' not in value
      {%- endif -%}:
        order.append('{{ indicator1['name'] }}')
    {%- endif -%}

    {%- if indicator2.get('name') %}

    if key[4] in indicator_map2
      {%- if indicator2.get('name') in reverse_subfields.keys() -%}
      {{ " " }}and '{{ reverse_subfields.get(indicator2.get('name')) }}' not in value
      {%- endif -%}:
        order.append('{{ indicator2['name'] }}')
    {%- endif %}

    return {
        '__order__': tuple(order) if len(order) else None,
    {%- for code, subfield in field.get('subfields').items() %}
      {%- if clean_name(subfield['name']) not in (indicator1['name'], indicator2['name']) %}
        {%- if subfield.get('repeatable', False) %}
        '{{ clean_name(subfield['name']) }}': utils.force_list(
            value.get('{{ code }}')
        ),
        {%- else %}
        '{{ clean_name(subfield['name']) }}': value.get('{{ code }}'),
        {%- endif %}
      {%- endif %}
    {%- endfor %}
    {%- if indicator1.get('name') %}
      {%- if indicator1.get('specified_in_subfield_ind') %}
        '{{ indicator1['name'] }}': value.get('{{ reverse_subfields.get(indicator1.get('name'), indicator1.get('specified_in_subfield')) }}') if key[3] == '{{ indicator1.get('specified_in_subfield_ind') }}' else indicator_map1.get(key[3]),
      {%- else %}
        '{{ indicator1['name'] }}': indicator_map1.get(key[3]),
      {%- endif %}
    {%- endif %}
    {%- if indicator2.get('name') %}
      {%- if indicator2.get('specified_in_subfield_ind') %}
        '{{ indicator2['name'] }}': value.get('{{ reverse_subfields.get(indicator2.get('name'), indicator2.get('specified_in_subfield')) }}') if key[4] == '{{ indicator2.get('specified_in_subfield_ind') }}' else indicator_map2.get(key[4]),
      {%- else %}
        '{{ indicator2['name'] }}': indicator_map2.get(key[4]),
      {%- endif %}
    {%- endif %}
    }
{%- else %}


@marc21.over('{{ clean_name(field.name) }}', '^{{ tag }}')
def {{ clean_name(field.name) }}(self, key, value):
    """{{ field.name }}."""
    return value
{%- endif %}
{%- endfor -%}
