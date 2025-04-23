// template.sci

function [x, y, typ] = {{ block.name }}(job, arg1, arg2)
  x = []; y = []; typ = [];

  // Initialize parameters to their defaults
  {% for p in block.parameters %} {{ p.name }} = {{ p.default | repr}}; {% endfor %}

  select job

  case 'set' then
    x        = arg1;
    graphics = x.graphics;
    exprs    = graphics.exprs;
    model    = x.model;

    // Build dialog labels & types
    labels = [...
      {% for p in block.parameters %}'{{ p.label }}'{% if not loop.last %}; {% endif %}{% endfor %}...
    ];
    types = list(...
      {% for p in block.parameters %}"{{ p.type }}", 1{% if not loop.last %}, {% endif %}{% endfor %}...
    );
 
    [ok, {% for p in block.parameters %} {{ p.name }}{% if not loop.last %}, {% endif %}{% endfor %}, exprs] = ...
      getvalue("Set {{ block.name }} parameters", labels, types, exprs);

    if ok then
      
      // cast and unpack the user parameters
      {% for p in block.parameters -%}
      {% if p.type == "str" -%}
      {{ p.name }} = p.name;
      {% else -%}
      {{ p.name }} = evstr({{ p.name }});
      {% endif -%}
      {% endfor %}

      graphics.exprs = exprs;

      // update the ports
      model.in   = [ {% for ip in block.inputs  %}{{ ip.rows }}{% if not loop.last %}, {% endif %}{% endfor %} ];
      model.in2  = [ {% for ip in block.inputs  %}{{ ip.cols_param }}{% if not loop.last %}, {% endif %}{% endfor %} ];
      model.out  = [ {% for op in block.outputs %}{{ op.rows }}{% if not loop.last %}, {% endif %}{% endfor %} ];
      model.out2 = [ {% for op in block.outputs %}{{ op.cols_param }}{% if not loop.last %}, {% endif %}{% endfor %} ];
      
    end

  case 'define' then
    model = scicos_model();
    model.sim       = list('{{ block.name }}', {{ block.sim_type }});
    model.blocktype = '{{ block.blocktype }}';
    model.rpar      = [...
      {% for p in block.parameters if p.type != "str" %}{{ p.default }}{% if not loop.last %}, {% endif %}{% endfor %}...
    ];

    // initialize ports
    model.in   = [ {% for ip in block.inputs  %}{{ ip.rows }}{% if not loop.last %}, {% endif %}{% endfor %} ];
    model.in2  = [ {% for ip in block.inputs  %}{{ ip.cols_param }}{% if not loop.last %}, {% endif %}{% endfor %} ];
    model.out  = [ {% for op in block.outputs %}{{ op.rows }}{% if not loop.last %}, {% endif %}{% endfor %} ];
    model.out2 = [ {% for op in block.outputs %}{{ op.cols_param }}{% if not loop.last %}, {% endif %}{% endfor %} ];

    exprs = [...
      {% for p in block.parameters %}'{{ p.default }}'{% if not loop.last %}; {% endif %}{% endfor %}...
    ];
    gr_i = [];  // can populate this if   blocks all share a default icon

    x = standard_define(...
      [{{ block.graphics.width }} {{ block.graphics.height }}],...
      model, exprs, gr_i...
    );

    // add input ports
    x.graphics.in_label     = [{% for ip in block.inputs  %}{{ ip.name | repr}}{% if not loop.last %}, {% endif %}{% endfor %}];
    x.graphics.in_implicit  = [{% for ip in block.inputs  %}'{{ ip.implicit|ternary("I","E") }}'{% if not loop.last %}, {% endif %}{% endfor %}];

    // add output ports
    x.graphics.out_label    = [{% for op in block.outputs %} {{ op.name | repr}}{% if not loop.last %}, {% endif %}{% endfor %}];
    x.graphics.out_implicit = [{% for op in block.outputs %}'{{ op.implicit|ternary("I","E") }}'{% if not loop.last %}, {% endif %}{% endfor %}];

    // style the module
    x.graphics.style        = "{{ block.graphics.style }}";
    x.model.label           = "{{ block.label }}";

  end
endfunction
