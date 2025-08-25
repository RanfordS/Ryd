
syn match RydCommandChar "[\[|\]]"
syn match RydGroupChar "[{}]"
syn match RydCommand "\[[^\[|\]]*[\]|]" contains=@NoSpell

syn match RydConceal "\[{\]" conceal cchar={
syn match RydConceal "\[}\]" conceal cchar=}
syn match RydConceal "\[l\]" conceal cchar=[
syn match RydConceal "\[r\]" conceal cchar=]
syn match RydConceal "\[|\]" conceal cchar=|

syn region RydLuaCommand start="\[lua|" end="\]" contains=@NoSpell
syn region RydLua start="\(\[lua|\)\@<=" end="\(\]\)\@=" contained containedin=RydLuaCommand contains=@NoSpell
syn region RydLua start=_\[_ end=_\]_ contained containedin=RydLua contains=@NoSpell

syn region RydLuaString start=_\z(['"]\)_ skip=_\\._ end=_\z1_ contained containedin=RydLua
syn match RydLuaStringEscape _\\._ contained containedin=RydLuaString
syn region RydLuaBlockString start=_\[\z(=*\)\[_ end=_\]\z1\]_ contained containedin=RydLua

syn match RydLuaComment "--.*$" contained containedin=RydLua
syn region RydLuaBlockComment start="--\[\z(=*\)\[" end="\]\z1\]" contained containedin=RydLua

syn keyword RydLuaKeyword and break do else elseif end for function in local not or repeat return then until while contained containedin=RydLua
syn keyword RydLuaConstant true false nil contained containedin=RydLua

hi link RydCommandChar Keyword
hi link RydGroupChar Type
hi link RydCommand Keyword
hi link RydConceal Conceal

hi link RydLuaCommand Macro
hi link RydLuaString String
hi link RydLuaStringEscape Special
hi link RydLuaBlockString String
hi link RydLuaComment Comment
hi link RydLuaBlockComment Comment
hi link RydLuaKeyword Keyword
hi link RydLuaConstant Constant

