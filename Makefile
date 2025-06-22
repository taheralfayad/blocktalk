# Makefile

IP_ADDRESS=YOUR_MACHINE_IP_ADDRESS

run:
ifeq ($(IP_ADDRESS),YOUR_MACHINE_IP_ADDRESS)
	@echo "Please set the IP_ADDRESS variable in the Makefile to your machine's IP address."
else
	flutter run --dart-define=BACKEND_URL=$(IP_ADDRESS):8080
endif
