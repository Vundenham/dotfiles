if status is-login
    if test -z "$DISPLAY"
        if test (tty) = "/dev/tty1"
            exec start-hyprland
        end
    end
end

# Hermes Agent — ensure ~/.local/bin is on PATH
fish_add_path "$HOME/.local/bin"
