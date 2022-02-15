# -*- coding: utf-8 -*-
#
# This file is part of DoJSON
# Copyright (C) 2015, 2016 CERN.
#
# DoJSON is free software; you can redistribute it and/or
# modify it under the terms of the Revised BSD License; see LICENSE
# file for more details.

"""To MARC 21 model definition."""

from dojson import utils

from ..model import to_marc21

{%- for tag, field in data if tag|length() == 3 %}
{%- if 'subfields' in field %}

{%- set indicator1 = get_indicator(1, field) %}
{%- set indicator2 = get_indicator(2, field) %}


@to_marc21.over('{{ tag }}', '^{{ clean_name(field.name) }}$')
{%- if field.repeatable %}
@utils.reverse_for_each_value
{%- endif %}
@utils.filter_values
def reverse_{{ clean_name(field.name) }}(self, key, value):
    """Reverse - {{ field.name }}."""
    {%- if indicator1.get('name') %}
      {%- if indicator1.get('name') == 'nonfiling_characters' %}
    indicator_map1 = {str(x): str(x) for x in range(10)}
      {%- else %}
    indicator_map1 = {{ tojson(reverse_indicator_dict(indicator1.get('values', {}))) }}
      {%- endif %}
    {%- endif %}
    {%- if indicator2.get('name') %}
      {%- if indicator2.get('name') == 'nonfiling_characters' %}
    indicator_map2 = {str(x): str(x) for x in range(10)}
      {%- else %}
    indicator_map2 = {{ tojson(reverse_indicator_dict(indicator2.get('values', {}))) }}
      {%- endif %}
    {%- endif %}

    {%- set subfields = dict() %}
    {%- set reverse_subfields = dict() %}
    field_map = {
      {%- for code, subfield in field.get('subfields').items() %}
        '{{ clean_name(subfield['name']) }}': '{{ code }}',
        {%- do subfields.update({code: clean_name(subfield['name'])}) %}
        {%- do reverse_subfields.update({clean_name(subfield['name']): code}) %}
      {%- endfor %}
    }

    order = utils.map_order(field_map, value)

    {%- if indicator1.get('name') %}

    if indicator_map1.get(value.get('{{ indicator1.get('name') }}'), '7') != '7':
        try:
            order.remove(field_map.get('{{ indicator1.get('name') }}'))
        except ValueError:
            pass

    {%- endif %}

    {%- if indicator2.get('name') %}

    if indicator_map2.get(value.get('{{ indicator2.get('name') }}'), '7') != '7':
        try:
            order.remove(field_map.get('{{ indicator2.get('name') }}'))
        except ValueError:
            pass

    {%- endif %}

    return {
        '__order__': tuple(order) if len(order) else None,
    {%- for code, subfield in field.get('subfields').items() %}
      {%- if subfield.get('repeatable', False) %}
        '{{ code }}': utils.reverse_force_list(
            value.get('{{ clean_name(subfield['name']) }}')
        ),
      {%- else %}
        '{{ code }}': value.get('{{ clean_name(subfield['name']) }}'),
      {%- endif %}
    {%- endfor %}
    {%- if indicator1.get('name') %}
        {%- if indicator1.get('specified_in_subfield_ind') and subfields.get(indicator1.get('specified_in_subfield')) %}
        '$ind1': '{{ indicator1.get('specified_in_subfield_ind') }}' if '{{ indicator1['name'] }}' in value and
        not indicator_map1.get(value.get('{{ indicator1['name'] }}')) and
        value.get('{{ indicator1['name']}}') == value.get('{{ subfields.get(indicator1.get('specified_in_subfield')) }}')
        else indicator_map1.get(value.get('{{ indicator1['name']}}'), '_'),
        {%- else %}
        '$ind1': indicator_map1.get(value.get('{{ indicator1['name'] }}'), '_'),
        {%- endif %}
    {%- else %}
        '$ind1': '_',
    {%- endif %}
    {%- if indicator2.get('name') %}
        {%- if indicator2.get('specified_in_subfield_ind') and subfields.get(indicator2.get('specified_in_subfield')) %}
        '$ind2': '{{ indicator2.get('specified_in_subfield_ind') }}' if '{{ indicator2['name'] }}' in value and
        not indicator_map2.get(value.get('{{ indicator2['name'] }}')) and
        value.get('{{ indicator2['name']}}') == value.get('{{ subfields.get(indicator2.get('specified_in_subfield')) }}')
        else indicator_map2.get(value.get('{{ indicator2['name']}}'), '_'),
        {%- else %}
        '$ind2': indicator_map2.get(value.get('{{ indicator2['name'] }}'), '_'),
        {%- endif %}
    {%- else %}
        '$ind2': '_',
    {%- endif %}
    }
{%- else %}


@to_marc21.over('{{ tag }}', '^{{ clean_name(field.name) }}$')
def reverse_{{ clean_name(field.name) }}(self, key, value):
    """Reverse - {{ field.name }}."""
    return [value]
{%- endif %}
{%- endfor %}
