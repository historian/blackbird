# Transitions

Transitions aims to remove traditional ActiveRecord migrations and replace it with DataMapper-like automatic migrations mixed with event based data patching.

The major advantage of Transitions over migrations is that it allows Rails engines to define there own schemas which get automatically loaded in the application. The application remains in full control as it can overwrite an engines schema.

## Quick Start Guide

    #!/usr/bin/env bash
    gem install transitions

    ./Gemfile
    gem "rails", "3.0.0.beta3"
    gem "transitions"
