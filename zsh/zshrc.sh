function main() {
    setup_aliases
}

function setup_aliases() {
    alias pmr="python manage.py runserver"
    alias pms="python manage.py shell"
    alias pmsp="python manage.py shell_plus"
    alias dcd="docker-compose -f docker-compose.dev.yml"
}

main
