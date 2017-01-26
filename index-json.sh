echo '{"posts": ['
    find blog/ -type f -name '*.md' -exec ./meta.sh {} \; | head -c -2
echo ']}'
