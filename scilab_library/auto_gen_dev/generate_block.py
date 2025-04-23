#!/usr/bin/env python3

import tomli
from jinja2 import Template, FileSystemLoader, Environment
from pathlib import Path
import json

AUTOGEN_CONFIG_DIR  = Path(".")
AUTOGEN_OUT_DIR     = Path("../scilab_blocks/casper_dsp_autogen")

# Load TOML
def load_config(toml_path):
    with open(toml_path, "rb") as f:
        return tomli.load(f)

def ternary(cond, true_expr, false_expr):
    return true_expr if cond else false_expr

def build_json(blk):
    """
    Construct the JSON-metadata dict for one block.
    Matches the 'parameters.keys' / 'parameters.values' format.
    """
    # base keys
    keys   = ["name", "fullpath", "tag"]
    values = [blk["name"], blk.get("fullpath", ""), blk.get("tag", "")]

    # then all block-specific parameters in order
    for p in blk.get("parameters", []):
        keys.append(p["name"])
        values.append(p["default"])

    return {"parameters": {"keys": keys, "values": values}}


def generate_block(config_path, out_dir):
    """automatically generate a pair of .sci and .json files from the given .toml config file"""
    # initialize the template object
    loader = FileSystemLoader('.')
    env = Environment(autoescape=False, loader=loader)
    env.filters['str'] = str
    env.filters['repr'] = repr
    env.filters['ternary'] = ternary
    temp = env.get_template('template.sci')
    
    # load block configuration and Scilab template file.
    cfg = load_config(config_path)
    template_str = Path("template.sci").read_text()
    
    # fill in the template with tthe block parameters.
    blk = cfg.get("block", [])
    sci_code = temp.render(block=blk) #render_block(blk, template_str)

    # get json config
    json_cfg = build_json(blk)
    
    # write rendered template and JSON to file.
    sci_fpath = out_dir / f"{blk['name']}.sci"
    sci_fpath.write_text(sci_code)
    json_fpath = out_dir / f"{blk['name']}.json"
    with open(json_fpath, 'w') as fp:
        json.dump(json_cfg, fp, indent=4)
    print(f"Wrote generated {blk['name']}.sci and {blk['name']}.json to '{out_dir}'")


def generate_all_blocks(config_dir=AUTOGEN_CONFIG_DIR, out_dir=AUTOGEN_OUT_DIR):
    assert AUTOGEN_CONFIG_DIR.exists(),f"the given config directory '{AUTOGEN_CONFIG_DIR} does not exist!"
    assert AUTOGEN_OUT_DIR.exists(),f"the given out directory '{AUTOGEN_OUT_DIR} does not exist!"
    
    autogen_config_files = list(AUTOGEN_CONFIG_DIR.glob("*.toml"))
    for f in autogen_config_files:
        assert f.exists()
        config_path = config_dir / f
        generate_block(config_path, out_dir)
    

if __name__ == "__main__":
    generate_all_blocks()
