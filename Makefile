UID := $(shell id -u)
DKR_CMP := env UID=$(UID) docker compose --project-directory=.

define dkr-cmp
	$(DKR_CMP) $1
endef

define dkr-cmp-up-exec-app
	$(DKR_CMP) up --detach
	$(DKR_CMP) exec app $1 || true
	$(DKR_CMP) down
endef


.PHONY: build
build:
	$(call dkr-cmp,build --build-arg UID=$(UID))

.PHONY: local
local:
	$(call dkr-cmp,run app npm run server)

.PHONY: local-attach-app
local-attach-app:
	$(call dkr-cmp-up-exec-app,bash --login)
