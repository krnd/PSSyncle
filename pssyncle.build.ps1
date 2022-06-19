#Requires -Version 5.1

# cspell:ignore pssyncle, psmodule
# cspell:ignore psrepo, psrepository


# ################################ TASKS #######################################

TASK .

TASK sync     pssyncle:sync
TASK setup    psmodule:setup
TASK publish  psmodule:publish
TASK psrepo   psmodule:show:psrepository
