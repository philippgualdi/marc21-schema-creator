# -*- coding: utf-8 -*-
#
# This file is part of JSONAlchemy.
# Copyright (C) 2015 CERN.
#
# JSONAlchemy is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 2 of the
# License, or (at your option) any later version.
#
# JSONAlchemy is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with JSONAlchemy; if not, write to the Free Software Foundation, Inc.,
# 59 Temple Place, Suite 330, Boston, MA 02111-1307, USA.

"""MARC 21 model definition."""


from jsonalchemy import dsl
from jsonalchemy import utils


class Record(dsl.Model):

    {%- for tag, field in data if tag|length() == 3 %}
    {%- if 'subfields' in field %}

    {%- set indicator1 = get_indicator(1, field) %}
    {%- set indicator2 = get_indicator(2, field) %}

    {{ clean_name(field.name) }} = {{ 'dsl.List(' if field.repeatable else '' }}dsl.Object(
    {%- for code, subfield in field.get('subfields').iteritems() %}
        {{ clean_name(subfield['name']) }} = dsl.Field(),
    {%- endfor %}
    {%- if indicator1.get('name') %}
        {{ indicator1['name'] }} = dsl.Field(),
    {%- endif %}
    {%- if indicator2.get('name') %}
        {{ indicator2['name'] }} = dsl.Field(),
    {%- endif %}
    ){{ ')' if field.repeatable else '' }}

    @{{ clean_name(field.name) }}.creator('marc', '{{ tag }}{{ indicator1['re'] }}{{ indicator2['re'] }}')
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

    {{ clean_name(field.name) }} = dsl.Field()

    @{{ clean_name(field.name) }}.creator('marc', '{{ tag }}')
    def {{ clean_name(field.name) }}(self, key, value):
        return value
    {%- endif %}
    {%- endfor %}
