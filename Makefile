VIM = vim -N -u NORC -i NONE --cmd 'set rtp+=test/deps/vim-vader rtp+=$$PWD'

test: test/deps/vim-vader
	$(VIM) '+Vader! test/*.vader'

testnvim: test/deps/vim-vader
	VADER_OUTPUT_FILE=/dev/stderr n$(VIM) --headless '+Vader! test/*.vader'

testinteractive: test/deps/vim-vader
	$(VIM) '+Vader test/*.vader'

test/deps/vim-vader:
	git clone https://github.com/junegunn/vader.vim test/deps/vim-vader || ( cd test/deps/vim-vader && git pull --rebase; )

.PHONY: test testnvim testinteractive
