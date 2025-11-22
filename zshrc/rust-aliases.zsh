# Rust Replacements (Modern CLI tools)

# 1. bat (Better cat)
if command -v bat > /dev/null; then
    alias cat='bat'
fi

# 2. eza (Better ls)
if command -v eza > /dev/null; then
    alias ls='eza --icons'
    alias ll='eza --icons -l -g --git'
    alias la='eza --icons -a'
    alias tree='eza --icons --tree'
fi

# 3. zoxide (Better cd)
# Zoxide usually needs an init command, not just an alias
if command -v zoxide > /dev/null; then
    eval "$(zoxide init zsh)"
    alias cd='z'
fi

# 4. ripgrep (Better grep)
if command -v rg > /dev/null; then
    alias grep='rg'
fi

# 5. fd (Better find)
if command -v fd > /dev/null; then
    alias find='fd'
fi

# 6. dust (Better du)
if command -v dust > /dev/null; then
    alias du='dust'
fi
