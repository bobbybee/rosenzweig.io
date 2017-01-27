echo '{"posts": ['
    OUT=$(ls -1 --sort=time blog/*.md | xargs -n 1 ./meta.sh)
    echo $OUT | head -c -2
echo ']}'
