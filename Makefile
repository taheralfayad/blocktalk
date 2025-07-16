# Makefile
include .env
export

run:
ifeq ($(IP_ADDRESS),YOUR_MACHINE_IP_ADDRESS)
	@echo "Please set the IP_ADDRESS variable in the Makefile to your machine's IP address."
else ifeq ($(MAPTILER_API_KEY),YOUR_MAPTILER_API_KEY)
	@echo "Please set the MAPTILER_API_KEY variable in the Makefile to your MapTiler API key."
else
	flutter run --dart-define='BACKEND_URL=$(IP_ADDRESS):8080' --dart-define='MAPTILER_API_KEY=$(MAPTILER_API_KEY)'
endif
