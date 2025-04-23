// slice_AUTOGEN.sci

function [x, y, typ] = slice_AUTOGEN(job, arg1, arg2)
  x = []; y = []; typ = [];

  // Initialize parameters to their defaults
  blkname = 'slice_AUTOGEN';
  input_width = 32;
  output_width = 1;
  slice_start = 0;
  

  select job
    case 'set' then
      x         = arg1;
      graphics  = x.graphics;
      exprs     = graphics.exprs;
      model     = x.model;

      // Build dialog labels & types
      labels = [...
        'Block Name'; 'Input bit width'; 'Output bit width'; 'Starting index of slice'...
      ];
      types = list(...
        "str", 1, "intvec", 1, "intvec", 1, "intvec", 1...
      );
  
      [ok,  blkname,  input_width,  output_width,  slice_start, exprs] = ...
        getvalue("Set slice_AUTOGEN parameters", labels, types, exprs);

      if ok then
        
        /*
        // cast and unpack the user parameters
        blkname = blkname;
        input_width = evstr(input_width);
        output_width = evstr(output_width);
        slice_start = evstr(slice_start);
        
        */

        // update the block style
        graphics.exprs = exprs;
        graphics.style  = "shape=rectangle;fillColor=green";

        // update the ports
        model.in   = [ 1 ];
        model.in2  = [ input_width ];
        model.out  = [ 1 ];
        model.out2 = [ output_width ];

        x.model = model;
        x.graphics = graphics;
      end

    case 'define' then
      model = scicos_model();
      model.sim       = list('slice_AUTOGEN', 4);
      model.blocktype = 'c';
      // model.rpar : I don't think we need to set this, but I'll leave it here for later in case we do.
      /*
      model.rpar      = [...
        32, 1, 0...
      ];
      */

      // initialize ports
      model.in   = [ 1 ];
      model.in2  = [ input_width ];
      model.out  = [ 1 ];
      model.out2 = [ output_width ];

      exprs = [...
        'slice_AUTOGEN'; '32'; '1'; '0'...
      ];
      gr_i = [];  // we use this field to configure the style of the blocks.

      x = standard_define(...
        [4 8],...
        model, exprs, gr_i...
      );

      // add input ports
      x.graphics.in_label     = ['in'];
      x.graphics.in_implicit  = ['E'];

      // add output ports
      x.graphics.out_label    = [ 'out'];
      x.graphics.out_implicit = ['E'];

      // style the module
      x.graphics.style        = "shape=rectangle;fillColor=green";
      x.model.label           = "dsp";

  end
endfunction