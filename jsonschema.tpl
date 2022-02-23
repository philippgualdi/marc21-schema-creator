{%- macro render_object(field) -%}
    {%- set indicator1 = get_indicator(1, field) -%}
    {%- set indicator2 = get_indicator(2, field) -%}

    "type":"object",
    "properties": {
    {%- if indicator1.get('name') %}
        "ind1": {
          {%- if indicator1.get('specified_in_subfield') %}
            "type": "string"
          {%- elif indicator1.get('name') == 'nonfiling_characters' %}
            "enum": {{ tojson(set(map(int_to_str, range(10)))) }}
          {%- else %}
            "enum": {{ tojson(set(map(int_to_str, indicator1.get('values', {}).keys()))) }}
          {%- endif %}
        },
    {%- endif %}
    {%- if indicator2.get('name') %}
        "ind2": {
          {%- if indicator2.get('specified_in_subfield') %}
            "type": "string"
          {%- elif indicator2.get('name') == 'nonfiling_characters' %}
            "enum": {{ tojson(set(map(int_to_str, range(10)))) }}
          {%- else %}
            "enum": {{ tojson(set(map(int_to_str, indicator2.get('values', {}).keys()))) }}
          {%- endif %}
        },
    {%- endif %}
    {%- set subfields = field.get('subfields') -%}
    {%- if subfields %}
        "subfields": {
            "type":"array" ,
            "items": {
                "type": "object",
                "additionalProperties":false,
                "properties":{
                {%- for code, subfield in subfields.items() %}
                    "{{ code }}": {
                        "description": "{{ subfield.name }}",
                        "type": "string"
                    }{{ ',' if not loop.last }}
                {%- endfor %}
                }
            }
        }
    {%- endif %}
    }
{%- endmacro -%}
{
    "type": "object",
    "properties": {
        "leader": {
        "type": "string"
        },
        "fields": {
            "type":"object",
            "properties": {
            {%- for tag, field in data if tag|length() == 3 %}
            {%- if 'subfields' in field %}
                "{{ tag }}": {
                    "description": "{{ field.name }}",
                    "type": "array",
                {%- if not field.repeatable %}
                    "maxItems": 1,
                {% endif%}
                    "items": {
                        {{- render_object(field)|indent(20) }}
                    }
                }{{ ',' if not loop.last }}
            {%- else %}
                "{{ tag }}": {
                    "description": "{{ field.name }}",
                    "type": "string"
                }{{ ',' if not loop.last }}
                {%- endif %}
            {%- endfor %}
            }
        }
    }
}
