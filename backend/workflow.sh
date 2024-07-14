#! /usr/bin/env bash

sqlx migrate revert --target-version 0
sqlx migrate run

gleam test
