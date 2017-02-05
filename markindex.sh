echo '<style>' > /tmp/open && echo '</style>'> /tmp/close
pandoc -f markdown -t html index.md --standalone --self-contained -H /tmp/open -H global.css -H /tmp/close> index.html
