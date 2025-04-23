// template.sci

function [x, y, typ] = adder_AUTOGEN(job, arg1, arg2)
  x = []; y = []; typ = [];

  // Initialize parameters to their defaults
  
  blkname = 'adder_AUTOGEN';
  
  a_bitwidth = 32;
  
  b_bitwidth = 32;
  
  c_bitwidth = 32;
  

  select job

  case 'set' then
    x        = arg1;
    graphics = x.graphics;
    exprs    = graphics.exprs;
    model    = x.model;

    // Build dialog labels & types
    labels = [...
      'Block Name', 'Input bit width (a)', 'Input bit width (b)', 'Output bit width (c)'...
    ];
    types = list(...
      "string", 1, "int", 1, "int", 1, "int", 1...
    );

    [ok,  blkname,  a_bitwidth,  b_bitwidth,  c_bitwidth, exprs] = ...
      getvalue("Set adder_AUTOGEN parameters", labels, types, exprs);

    if ok then
      
      blkname = strtod(blkname);
      
      a_bitwidth = strtod(a_bitwidth);
      
      b_bitwidth = strtod(b_bitwidth);
      
      c_bitwidth = strtod(c_bitwidth);
      

      graphics.exprs = exprs;
      [model, graphics, ok] = set_io(...
        model, graphics,...
        list(...
           1, a_bitwidth, "E",  1, b_bitwidth, "E"...
        ),...
        list(...
           1, c_bitwidth, "E"...
        )...
      );

      if ok then
        x.graphics = graphics;
        x.model    = model;
      end
    end

  case 'define' then
    model = scicos_model();
    model.sim       = list('adder_AUTOGEN', 4);
    model.blocktype = 'c';
    model.rpar      = [...
      32, 32, 32...
    ];
    model.in   = [ 1, 1 ];
    model.in2  = [ a_bitwidth, b_bitwidth ];
    model.out  = [ 1 ];
    model.out2 = [ c_bitwidth ];

    exprs = [...
      'adder_AUTOGEN'; '32'; '32'; '32'...
    ];
    gr_i = [];  // you can populate this if your blocks all share a default icon

    x = standard_define(...
      [4 8],...
      model, exprs, gr_i...
    );

    // Add input ports
    x.graphics.in_label     = ['in0', 'in1'];
    x.graphics.in_implicit  = ['E', 'E'];

    // Add output ports
    x.graphics.out_label    = [ 'out0'];
    x.graphics.out_implicit = ['E'];

    // Style module
    x.graphics.style        = "shape=rectangle;fillColor=green";
    x.model.label           = "dsp";

  end
endfunction