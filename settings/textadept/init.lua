view:set_theme('light', {font = 'Microsoft YaHei', size = 12})

buffer.use_tabs = false
buffer.tab_width = 4
buffer.eol_mode = buffer.EOL_LF

keys['ctrl+,'] = textadept.menu.menubar['Edit/Preferences'][2]
keys['shift+del'] = buffer.line_delete
keys['alt+up'] = buffer.move_selected_lines_up
keys['alt+down'] = buffer.move_selected_lines_down
keys['alt+z'] = textadept.menu.menubar['View/Toggle Wrap Mode'][2]
keys['alt+right'] = textadept.menu.menubar['Edit/Complete Word'][2]

textadept.editing.auto_pairs = nil -- disable completely
textadept.session.save_on_quit = false

