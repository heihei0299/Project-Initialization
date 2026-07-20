import os
import pathlib

cmds_dir = '.opencode/commands'
pathlib.Path(cmds_dir).mkdir(parents=True, exist_ok=True)

cmd_entries = {
    'gwd': {'desc': 'Run grill-with-docs',              'template': 'Run the grill-with-docs skill workflow.'},
    'ica': {'desc': 'Run improve-codebase-architecture', 'template': 'Run the improve-codebase-architecture skill workflow.'},
    'gm':  {'desc': 'Run grill-me',                      'template': 'Run the grill-me skill workflow.'},
    'tp':  {'desc': 'Run to-spec',                       'template': 'Run the to-spec skill workflow.'},
    'tc':  {'desc': 'Run to-tickets',                    'template': 'Run the to-tickets skill workflow.'},
    'cw':  {'desc': 'Run code-review',                   'template': 'Run the code-review skill workflow.'},
    'implement': {'desc': 'Run implement',               'template': 'Run the implement skill workflow.'},
}

for name, info in cmd_entries.items():
    md_path = os.path.join(cmds_dir, f'{name}.md')
    with open(md_path, 'w') as f:
        f.write('---\n')
        f.write(f'description: {info["desc"]}\n')
        f.write('---\n')
        f.write('\n')
        f.write(f'{info["template"]}\n')
