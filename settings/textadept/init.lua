local function shift_del()
    if buffer.selection_empty then
        buffer.line_cut()
    else
        buffer.cut()
    end
end

local function find_current_word()
    if buffer.selection_empty then
        textadept.editing.select_word()
    end
    ui.find.find_entry_text = buffer.get_sel_text()
    ui.find.find_next()
end

----------------------------------------------------------------------

view:set_theme('base16-monokai', {font = 'Microsoft YaHei', size = 12})

buffer.use_tabs = false
buffer.tab_width = 4
buffer.eol_mode = buffer.EOL_LF

keys['ctrl+,'] = textadept.menu.menubar['Edit/Preferences'][2]
keys['shift+del'] = shift_del
keys['alt+up'] = buffer.move_selected_lines_up
keys['alt+down'] = buffer.move_selected_lines_down
keys['alt+z'] = textadept.menu.menubar['View/Toggle Wrap Mode'][2]
keys['alt+right'] = textadept.menu.menubar['Edit/Complete Word'][2]
keys['ctrl+f3'] = find_current_word
keys['f3'] = ui.find.find_next

ui.find.highlight_all_matches = true
textadept.editing.auto_pairs = nil -- disable completely
textadept.session.save_on_quit = false

