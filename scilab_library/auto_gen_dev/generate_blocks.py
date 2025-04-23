import tomli
from jinja2 import Template, FileSystemLoader, Environment
from pathlib import Path

# Load TOML
def load_config(toml_path):
    with open(toml_path, "rb") as f:
        return tomli.load(f)

# Render one block
def render_block(block, template_str):
    print(block)    
    print(template_str)
    tmpl = Template(template_str)
    return tmpl.render(block=block)

def ternary(cond, true_expr, false_expr):
    return true_expr if cond else false_expr



def generate_blocks(out_dir = Path("generated_blocks")):
    loader = FileSystemLoader('.')
    env = Environment(autoescape=True, loader=loader)
    env.filters['repr'] = repr
    env.filters['ternary'] = ternary
    temp = env.get_template('template.sci')
    

    cfg = load_config("blocks.toml")
    template_str = Path("template.sci").read_text()
    
    out_dir.mkdir(exist_ok=True)
    for blk in cfg.get("block", []):
        sci_code = temp.render(block=blk) #render_block(blk, template_str)
        fname = f"{blk['name']}_AUTOGEN.sci"
        (out_dir / fname).write_text(sci_code)
        print(f"Wrote generated .sci file to '{out_dir / fname}'")

if __name__ == "__main__":
    generate_blocks()
