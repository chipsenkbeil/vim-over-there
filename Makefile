VIM = vim -N -u NORC -i NONE --cmd 'set rtp+=test/deps/vim-vader rtp+=$$PWD'

help: ## Display help information
	@printf 'usage: make [target] ...\n\ntargets:\n'
	@egrep '^(.+)\:\ .*##\ (.+)' ${MAKEFILE_LIST} | sed 's/:.*##/#/' | column -t -c 2 -s '#'

test: test/deps/vim-vader ## Runs tests for vim
	$(VIM) '+Vader! test/*.vader'

testnvim: test/deps/vim-vader ## Runs tests for neovim
	VADER_OUTPUT_FILE=/dev/stderr n$(VIM) --headless '+Vader! test/*.vader'

testinteractive: test/deps/vim-vader ## Runs tests interactively for vim
	$(VIM) '+Vader test/*.vader'

test/deps/vim-vader:
	git clone https://github.com/junegunn/vader.vim test/deps/vim-vader || ( cd test/deps/vim-vader && git pull --rebase; )

.PHONY: help test testnvim testinteractive
