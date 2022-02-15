{%- for tag, field in data if tag|length() == 3 %}

@extend
{{ clean_name(field.name) }}:
{%- if 'subfields' in field %}
    creator:
        @legacy((('{{ tag }}', '{{ tag }}__', '{{ tag}}__%'), ''),
        {%- for code, subfield in field.get('subfields').iteritems() %}
                ('{{ tag }}__{{ code }}', '{{ clean_name(subfield['name']) }}'){{ ')' if loop.last else ',' }}
        {%- endfor %}
        marc, '{{ tag }}..', {
        {%- for code, subfield in field.get('subfields').iteritems() -%}
            '{{ clean_name(subfield['name']) }}': value['{{ code }}']{{ '' if loop.last else ', ' }}
        {%- endfor -%}}
    producer:
        json_for_marc(), {
        {%- for code, subfield in field.get('subfields').iteritems() -%}
            '{{ tag }}__{{ code }}': '{{ clean_name(subfield['name']) }}'{{ '' if loop.last else ', ' }}
        {%- endfor -%}}
{%- else %}
    creator:
        @legacy(('{{ tag }}', ''), )
        marc, '{{ tag }}', value
    producer:
        json_for_marc(), {'{{ tag }}': ''}
{%- endif %}
{%- endfor %}
