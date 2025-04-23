// template.sci

function [x, y, typ] = adder_AUTOGEN(job, arg1, arg2)
  x = []; y = []; typ = [];

  // Initialize parameters to their defaults
   blkname = 'adder_AUTOGEN';  a_bitwidth = 32;  b_bitwidth = 32;  c_bitwidth = 32; 

  select job

  case 'set' then
    x        = arg1;
    graphics = x.graphics;
    exprs    = graphics.exprs;
    model    = x.model;

    // Build dialog labels & types
    labels = [...
      'Block Name'; 'Input bit width (a)'; 'Input bit width (b)'; 'Output bit width (c)'...
    ];
    types = list(...
      "str", 1, "intvec", 1, "intvec", 1, "intvec", 1...
    );
 
    [ok,  blkname,  a_bitwidth,  b_bitwidth,  c_bitwidth, exprs] = ...
      getvalue("Set adder_AUTOGEN parameters", labels, types, exprs);

    if ok then
      
      // cast and unpack the user parameters
      blkname = evstr(blkname);
      a_bitwidth = evstr(a_bitwidth);
      b_bitwidth = evstr(b_bitwidth);
      c_bitwidth = evstr(c_bitwidth);
      

      graphics.exprs = exprs;

      // update the ports
      model.in   = [ 1, 1 ];
      model.in2  = [ a_bitwidth, b_bitwidth ];
      model.out  = [ 1 ];
      model.out2 = [ c_bitwidth ];
      
    end

  case 'define' then
    model = scicos_model();
    model.sim       = list('adder_AUTOGEN', 4);
    model.blocktype = 'c';
    model.rpar      = [...
      adder_AUTOGEN, 32, 32, 32...
    ];

    // initialize ports
    model.in   = [ 1, 1 ];
    model.in2  = [ a_bitwidth, b_bitwidth ];
    model.out  = [ 1 ];
    model.out2 = [ c_bitwidth ];

    exprs = [...
      'adder_AUTOGEN'; '32'; '32'; '32'...
    ];
    gr_i = [];  // can populate this if   blocks all share a default icon

    x = standard_define(...
      [4 8],...
      model, exprs, gr_i...
    );

    // add input ports
    x.graphics.in_label     = ['in0', 'in1'];
    x.graphics.in_implicit  = ['E', 'E'];

    // add output ports
    x.graphics.out_label    = [ 'out0'];
    x.graphics.out_implicit = ['E'];

    // style the module
    x.graphics.style        = "shape=rectangle;fillColor=green";
    x.model.label           = "dsp";

  end
endfunction