.PHONY: help install run format lint typecheck check clean

help:
	@echo "FluentSoul mobile — commands"
	@echo "  make install   flutter pub get"
	@echo "  make run       flutter run"
	@echo "  make format    dart format lib"
	@echo "  make lint      flutter analyze"
	@echo "  make typecheck flutter analyze"
	@echo "  make check     dart format check and flutter analyze"
	@echo "  make clean     flutter clean"

install:
	flutter pub get

run:
	flutter run

format:
	dart format lib

lint:
	flutter analyze

typecheck:
	flutter analyze

check:
	dart format --set-exit-if-changed lib
	flutter analyze

clean:
	flutter clean
